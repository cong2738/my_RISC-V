int testF(int a, int b, int c);
int adder(int x, int y);
int sub(int x, int y);
int addPtr(int *x, int *y);
void sort(int * pData, int size);
void swap(int * d1, int * d2);

int gVar = 100;

int main(){
    int arData[6] = {5,3,1,2,4};

    sort(arData,5);

    int a, b, c, d, e, f, g;
    int *pA, *pB;

    pA = &a;
    pB = &b;

    a= 10;
    b = 20;
    c = adder(a,b);
    c = sub(b,a);
    d = *pA + *pB;

    d = 100;
    e = 200;
    f = e - d;

    g = addPtr(pA,pB);

    g = addPtr(&a,&b);

    while(a < 100) {
        a += 10;
    }

    while(1) {
        b -= 10;
    }

    return 0;
}

void sort(int * pData, int size){
    for( int j = 0 ; j < size-1; j++) {
        for (int i = 0; i < size-j-1; i++){
            if(pData[j] > pData[j+1]) {
                swap(&pData[j], &pData[i+1]);
            }
        }
    }
}

void swap(int * d1, int * d2){
    int tmp = *d1;
    *d1 = *d2;
    *d2 = tmp;
}

int adder(int x, int y){
    return x + y;
}

int addPtr(int *x, int *y){
    return *x + *y;
}

int *ptradd(int x, int y, int * ret){
    *ret = x+y;
    return ret;
}

int testF(int a, int b, int c){
    int arr1[10] = { 1,2,3,4,5,6,7,8,9,0};
    int res = a + b + c;
    return res;
}

int sub(int x, int y){
    return x - y;
}

int recursion(int x) {
    x += 10;
    if (x <= 100) recursion(x);
    return x;
}