const std = @import("std");
const mem = std.mem;
const math = std.math;
const testing = std.testing;

pub const Algorithm = enum { Quick, Insertion, Selection, Bubble };

/// sort and return the result (arr param)
pub fn sortR(comptime T: anytype, algorithm: ?Algorithm, arr: []T, desc: bool) []T {
    sort(T, algorithm, arr, desc);
    return arr;
}

/// sort to a owned slice
pub fn sortC(comptime T: anytype, algorithm: ?Algorithm, arr: []const T, desc: bool, allocator: *mem.Allocator) ![]T {
    var result = try allocator.alloc(T, arr.len);
    mem.copy(T, result, arr);
    return sortR(T, algorithm, result, desc);
}

/// sort array by given algorithm. default algorithm is Quick Sort
pub fn sort(comptime T: anytype, algorithm: ?Algorithm, arr: []T, desc: bool) void {
    if (algorithm == null) {
        quickSort(T, arr, 0, math.max(arr.len, 1) - 1, desc);
    } else {
        switch (algorithm.?) {
            .Bubble => bubbleSort(T, arr, desc),
            .Quick => quickSort(T, arr, 0, math.max(arr.len, 1) - 1, desc),
            .Insertion => insertionSort(T, arr, desc),
            .Selection => selectionSort(T, arr, desc),
        }
    }
}

pub fn bubbleSort(comptime T: anytype, arr: []T, desc: bool) void {
    var i: usize = 0;
    while (i < arr.len - 1) : (i += 1) {
        var j: usize = 0;
        while (j < arr.len - i - 1) : (j += 1) {
            if (flow(T, arr[j + 1], arr[j], desc)) {
                mem.swap(T, &arr[j], &arr[j + 1]);
            }
        }
    }
}

pub fn quickSort(comptime T: anytype, arr: []T, left: usize, right: usize, desc: bool) void {
    if (left < right) {
        const pivot = arr[right];
        var i = left;
        var j = left;
        while (j < right) : (j += 1) {
            if (flow(T, arr[j], pivot, desc)) {
                mem.swap(T, &arr[i], &arr[j]);
                i += 1;
            }
        }
        mem.swap(T, &arr[i], &arr[right]);
        quickSort(T, arr, left, math.max(i, 1) - 1, desc);
        quickSort(T, arr, i + 1, right, desc);
    }
}

pub fn insertionSort(comptime T: anytype, arr: []T, desc: bool) void {
    var i: usize = 1;
    while (i < arr.len) : (i += 1) {
        const x = arr[i];
        var j: usize = i;
        while (j > 0 and flow(T, x, arr[j - 1], desc)) : (j -= 1) {
            arr[j] = arr[j - 1];
        }
        arr[j] = x;
    }
}

pub fn selectionSort(comptime T: anytype, arr: []T, desc: bool) void {
    var i: usize = 1;
    while (i < arr.len) : (i += 1) {
        var pos = i - 1;
        var j = i;
        while (j < arr.len) : (j += 1) {
            if (flow(T, arr[j], arr[pos], desc)) {
                pos = j;
            }
        }
        mem.swap(T, &arr[pos], &arr[i - 1]);
    }
}

fn flow(comptime T: type, a: T, b: T, desc: bool) bool {
    if (desc)
        return a > b
    else
        return a < b;
}

pub fn mergeSort(comptime T: anytype, arr: []T, comptime left: usize, comptime right: usize, desc: bool) void {
    if (left >= right) return;
    const mid = left + (right - left) / 2;
    mergeSort(T, arr, left, mid, desc);
    mergeSort(T, arr, mid + 1, right, desc);
    const n1 = mid - left + 1;
    const n2 = right - mid;
    var L: [n1]T = undefined;
    var R: [n2]T = undefined;
    {
        var i: usize = 0;
        while (i < n1) : (i += 1) {
            L[i] = arr[left + i];
        }
    }
    {
        var j: usize = 0;
        while (j < n2) : (j += 1) {
            R[j] = arr[mid + 1 + j];
        }
    }
    var i: usize = 0;
    var j: usize = 0;
    var k = left;
    while (i < n1 and j < n2) : (k += 1) {
        if (flow(T, L[i], R[j], desc)) {
            arr[k] = L[i];
            i += 1;
        } else {
            arr[k] = R[j];
            j += 1;
        }
    }
    while (i < n1) {
        arr[k] = L[i];
        i += 1;
        k += 1;
    }
    while (j < n2) {
        arr[k] = R[j];
        j += 1;
        k += 1;
    }
}

const items = [_]u8{ 9, 1, 4, 12, 3, 4 };
const expectedASC = [_]u8{ 1, 3, 4, 4, 9, 12 };
const expectedDESC = [_]u8{ 12, 9, 4, 4, 3, 1 };

test "bubble" {
    {
        var arr = items;
        bubbleSort(u8, &arr, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        bubbleSort(u8, &arr, true);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "quick" {
    {
        var arr = items;
        quickSort(u8, &arr, 0, math.max(arr.len, 1) - 1, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        quickSort(u8, &arr, 0, math.max(arr.len, 1) - 1, true);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "insertion" {
    {
        var arr = items;
        insertionSort(u8, &arr, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        insertionSort(u8, &arr, true);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "selection" {
    {
        var arr = items;
        selectionSort(u8, &arr, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        selectionSort(u8, &arr, true);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "Merge" {
    {
        var arr = items;
        mergeSort(u8, &arr, 0, comptime math.max(arr.len, 1) - 1, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        mergeSort(u8, &arr, 0, comptime math.max(arr.len, 1) - 1, true);
        try testing.expect(mem.eql(u8, &arr, &expectedDESC));
    }
}

test "sort" {
    {
        var arr = items;
        sort(u8, null, &arr, false);
        try testing.expect(mem.eql(u8, &arr, &expectedASC));
    }
    {
        var arr = items;
        try testing.expect(mem.eql(u8, sortR(u8, null, &arr, false), &expectedASC));
    }
    {
        var arr = items;
        const c = try sortC(u8, null, &arr, false, std.testing.allocator);
        defer std.testing.allocator.free(c);
        try testing.expect(mem.eql(u8, c, &expectedASC));
        try testing.expect(mem.eql(u8, &arr, &items));
    }
}
