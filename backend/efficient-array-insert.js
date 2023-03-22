const findIndex = (arr, val) => {
    let low = 0, high = arr.length;
    while (low < high) {
        let mid = (low + high) >>> 1;
        if (arr[mid] < val) {
            low = mid + 1;
        }else {
            high = mid
        }
    };
    return low;
};
const insertInSortedArray = (arr = [], num) => {
    const position = findIndex(arr, num);
    for(let i = position; typeof arr[i] !== 'undefined'; i++){
        // swapping without using third variable num += arr[i];
        arr[i] = num - arr[i];
        num -= arr[i];
    }
    arr.push(num);
};