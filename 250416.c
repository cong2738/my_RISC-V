void sort(int *pData, int size);
void swap(int *pA, int *pB);
void sort(int *pData, int size);

int main(void) {
    int arData[6] = {5, 3, 1, 2, 4};
    sort(arData, 5);
}

void sort(int*pData, int size){
    for (int i=0; i<size - 1; i++) {
        for (int j=0; j<size-i-1; j++) {
            if (pData[j] > pData [j+1])
            swap(&pData[j], &pData[j+1]);
        }
    }
}

void swap(int *pA, int *pB) {
    int temp;
    temp = *pA;
    *pA = *pB;
    *pB = temp;
}