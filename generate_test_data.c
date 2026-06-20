#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define CEIL_DIV(a,b) ((a / b) + (a % b != 0))


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
 * @brief build the message schedule
 * 
 * @param input 
 * @return uint32_t*
 */
uint32_t* buildMessageSchedule(const uint32_t input[16]);

/**
 * @brief           compression loop
 * 
 * @param w         the message schedule to process
 * @param output    the 8-word output
 */
void compression(const uint32_t w[64], uint32_t* output);

/**
 * @brief           writes data to a text file in binary representation
 * 
 * @param data      the data to write
 * @param dataSize  the number of elements to write
 * @param filename  the name of the file being written
 */
void writeToFile(uint32_t* data, const int dataSize, const char* filename);

/**
 * @brief 
 * 
 * @param word 
 * @param string 
 */
void appendWordToString(uint32_t word, char* string);

// sha256 algo:
int main(int argc, char* argv[])
{
    int inputSize;
    uint32_t* inputBinary = convertInput(argv[1], &inputSize);

    writeToFile(inputBinary, inputSize, "input.txt");

    free(inputBinary);
    return;
}

uint32_t* convertInput(const char* input, int* size)
{
    uint64_t inputLength = (uint64_t)strlen(input);

    // inputLength = number of characters (8 bits each)
    // we want multiples 16x32 bits
    // ceiling division trick: (a / b) + (a % b != 0)
    // total size in bits = ceiling_division((inputLength * 8) + 1 + 64, 512)
    int numPages = CEIL_DIV(inputLength * 8 + 65, 512);
    uint32_t* inputBinary = calloc(numPages * 16, sizeof(uint32_t));

    memcpy(inputBinary, input, inputLength);
    
    // example: input = "abcd"
    // inputLength = 4 (32 bits)
    //                  a b c d \0
    // inputBinary = 0x61626364_00000000_00000000_00000000...
    // nullIndex = 1 (the index of the 32-bit word containing the null-index = inputLength/4)
    // placement = 3 * 8 (the amount to shift by = (3 - (inputLength % 4) * 8))
    inputBinary[inputLength/4] |= (0x80 << (3 - (inputLength % 4)) * 8);

    // at the very end of the binary block, the last 64 bits should be inputLength
    // each page is 512 bits (16 words)
    memcpy(inputBinary+(numPages*16+14), inputLength, sizeof(inputLength));

    *size = numPages * 16;
    return inputBinary;
}

void writeToFile(uint32_t* data, const int dataSize, const char* filename)
{
    FILE* outFile = fopen(filename, "w");
    if(outFile == NULL) return;

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
    stringbuf[dataSize*32] = '/0';

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