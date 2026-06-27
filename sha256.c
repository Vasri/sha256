#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define CEIL_DIV(a,b) (((a) / (b)) + (((a) % (b)) != 0))


/**
 * @brief               convert to binary, append with 1, then pad with 0s, then append 64 bits (size of input). 
 *                      Total block size will be a multiple of 16x 32-bit words (512 bits)
 * 
 * @param input         The input string to convert
 * @param size          The number of 32-bit words in the final data block
 * 
 * @return uint32_t*    Pointer to the data block allocated
 */
uint32_t* convertInput(const char* input, int* size);

/**
 * @brief           build the message schedule
 * 
 * @param input 
 * @param w         pointer to a 64-word block of data
 */
void buildMessageSchedule(const uint32_t* input, uint32_t* w);

/**
 * @brief           compression loop
 * 
 * @param w         the message schedule to process
 * @param h         the 8-word output
 */
void compression(const uint32_t* w, uint32_t* h);

/**
 * @brief           writes data to a text file in binary representation. The string to write is built by appendWordToString()
 * 
 * @param data      the data to write
 * @param dataSize  the number of elements to write
 * @param filename  the name of the file being written
 */
void writeToFile(uint32_t* data, const int dataSize, const char* filename);

/**
 * @brief           Convert one word at a time into 1s and 0s to build out a string
 * 
 * @param word      Word to append
 * @param string    String to build
 */
void appendWordToString(uint32_t word, char* string);

/**
 * @brief           Write data to file in hexadecimal representation.
 * 
 * @param data      the data to write
 * @param dataSize  the number of elements to write
 * @param filename  the name of the file being written
 */
void writeToFileHex(uint32_t* data, const int dataSize, const char* filename);

const uint32_t k[64] = 
                    {  
                        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
                        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
                        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
                        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
                        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
                        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
                        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
                        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
                    };

// sha256 algo:
int main(int argc, char* argv[])
{
    int inputSize;
    uint32_t* inputBinary = convertInput(argv[1], &inputSize);

    uint32_t h[8] = {   0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19};
    
    writeToFile(inputBinary, inputSize, "input.txt");
    writeToFileHex(inputBinary, inputSize, "input_hex.txt");

    // main processing loop: message schedule and compress
    uint32_t* w = calloc(64, sizeof(uint32_t));
    for (int i = 0; i < inputSize; i += 16)
    {
        buildMessageSchedule(inputBinary + i, w);
        writeToFileHex(w, 64, "message_schedule_hex.txt");
        compression(w, h);
        writeToFileHex(h, 8, "hash_values_hex.txt");
    }

    free(inputBinary);
    free(w);

    writeToFileHex(h, 8, "final_hash.txt");
    return 0;
}

uint32_t* convertInput(const char* input, int* size)
{
    if (input == NULL) 
        return NULL;
    uint64_t inputLength = (uint64_t)strlen(input);

    // inputLength = number of characters (8 bits each)
    // we want multiples 16x32 bits
    // ceiling division trick: (a / b) + (a % b != 0)
    // total size in bits = ceiling_division((inputLength * 8) + 1 + 64, 512)
    int numPages = CEIL_DIV(inputLength * 8 + 65, 512);
    uint32_t* inputBinary = calloc(numPages * 16, sizeof(uint32_t));
    if (inputBinary == NULL) 
        return NULL;

    for (uint64_t i = 0; i < inputLength; i++) {
        int wordIndex = i / 4;
        int byteIndexInWord = i % 4;        // 0 = most significant byte
        int shift = (3 - byteIndexInWord) * 8;
        inputBinary[wordIndex] |= ((uint32_t)(uint8_t)input[i]) << shift;
    }
    
    // example: input = "abcd"
    // inputLength = 4 (32 bits)
    //                  a b c d \0
    // inputBinary = 0x61626364_00000000_00000000_00000000...
    // nullIndex = 1 (the index of the 32-bit word containing the null-index = inputLength/4)
    // placement = 3 * 8 (the amount to shift by = (3 - (inputLength % 4) * 8))
    inputBinary[inputLength/4] |= (0x80 << ((3 - inputLength % 4)) * 8);

    // at the very end of the binary block, the last 64 bits should be inputLength
    // each page is 512 bits (16 words)
    inputLength *= 8;
    uint32_t lengthHigh = (uint32_t)(inputLength >> 32);
    uint32_t lengthLow  = (uint32_t)(inputLength & 0xFFFFFFFF);

    inputBinary[numPages*16 - 2] = lengthHigh;
    inputBinary[numPages*16 - 1] = lengthLow;

    *size = numPages * 16;
    return inputBinary;
}

static inline uint32_t rightrotate(uint32_t input, int amount)
{
    return (input << (32 - amount)) | (input >> (amount));
}

void buildMessageSchedule(const uint32_t* input, uint32_t* w)
{
    memcpy(w, input, 16*sizeof(uint32_t));

    uint32_t s0;
    uint32_t s1;

    for (int i = 16; i < 64; i++) 
    {
        s0 = (rightrotate(w[i-15], 7)) ^ (rightrotate(w[i-15], 18)) ^ (w[i-15] >> 3);
        s1 = (rightrotate(w[i-2], 17)) ^ (rightrotate(w[i-2], 19)) ^ (w[i-2] >> 10);
        w[i] = w[i-16] + s0 + w[i-7] + s1;
    }
}

void compression(const uint32_t* w, uint32_t* hash)
{
    uint32_t working[8];
    for (int i = 0; i < 8; i++)
    {
        working[i] = hash[i];
    }

    uint32_t s1;
    uint32_t ch;
    uint32_t temp1;
    uint32_t s0;
    uint32_t maj;
    uint32_t temp2;
    for (int i = 0; i < 64; i++)
    {
        s1 = rightrotate(working[4], 6) ^ rightrotate(working[4], 11) ^ rightrotate(working[4], 25);
        ch = (working[4] & working[5]) ^ ((~working[4]) & working[6]);
        temp1 = working[7] + s1 + ch + k[i] + w[i];
        s0 = rightrotate(working[0], 2) ^ rightrotate(working[0], 13) ^ rightrotate(working[0], 22);
        maj = (working[0] & working[1]) ^ (working[0] & working[2]) ^ (working[1] & working[2]);
        temp2 = s0 + maj;
        working[7] = working[6];
        working[6] = working[5];
        working[5] = working[4];
        working[4] = working[3] + temp1;
        working[3] = working[2];
        working[2] = working[1];
        working[1] = working[0];
        working[0] = temp1 + temp2;
    }

    for (int i = 0; i < 8; i++)
    {
        hash[i] += working[i];
    }
}

void writeToFile(uint32_t* data, const int dataSize, const char* filename)
{
    FILE* outFile = fopen(filename, "w");
    if(outFile == NULL) 
        return;

    char* stringbuf = malloc(dataSize*32 + 1);
    if (stringbuf == NULL)
    {
        fclose(outFile);
        return;
    }

    for (int i = 0; i < dataSize; i++)
    {
        appendWordToString(data[i], &stringbuf[i*32]);
    }
    stringbuf[dataSize*32] = 0;

    fprintf(outFile, "%s", stringbuf);
    fclose(outFile);
    free(stringbuf);
}

void appendWordToString(uint32_t word, char* string)
{
    for (int i = 31; i >= 0; i--)
    {
        string[i] = (word & 0x1) + '0';
        word = word >> 1;
    }
}

void writeToFileHex(uint32_t* data, const int dataSize, const char* filename)
{
    FILE* outFile = fopen(filename, "w");
    if(outFile == NULL) 
        return;

    char* stringbuf = malloc(dataSize*9 + 1);
    if (stringbuf == NULL)
    {
        fclose(outFile);
        return;
    }

    for (int i = 0; i < dataSize; i++)
    {
        sprintf(stringbuf, "%08X\n", data[i]);
        stringbuf += 9;
    }
    stringbuf -= dataSize * 9;
    stringbuf[dataSize*9] = 0;

    fprintf(outFile, "%s", stringbuf);
    fclose(outFile);
    free(stringbuf);
}
