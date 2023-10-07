// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract PriorityHeap {
    Task[] public heap;
    
    struct Task {
        uint id;
        uint priority;
    }

    // Inserta una tarea en el heap
    function insert(uint id, uint priority) public {
        Task memory newTask = Task(id, priority);
        heap.push(newTask);
        bubbleUp(heap.length - 1);
    }

    // Sube la tarea en la posición index hacia arriba en el heap para mantener la propiedad de heap
    function bubbleUp(uint index) internal {
        while (index > 0 && heap[parent(index)].priority > heap[index].priority) {
            // Usa una variable temporal para hacer el intercambio en dos pasos
            Task memory temp = heap[index];
            heap[index] = heap[parent(index)];
            heap[parent(index)] = temp;

            index = parent(index);
        }
    }

    // Devuelve el índice del padre del nodo en el índice dado
    function parent(uint index) internal pure returns (uint) {
        return (index - 1) / 2;
    }

    // Elimina y devuelve la tarea de mayor prioridad (menor valor) del heap
    function extractMin() public returns (Task memory) {
        require(heap.length > 0, "No tasks in the heap");
        Task memory min = heap[0];
        heap[0] = heap[heap.length - 1];
        heap.pop();
        bubbleDown(0);
        return min;
    }

    // Baja la tarea en la posición index hacia abajo en el heap para mantener la propiedad de heap
    function bubbleDown(uint index) internal {
        uint smallest = index;
        uint leftChild = 2 * index + 1;
        uint rightChild = 2 * index + 2;

        if (leftChild < heap.length && heap[leftChild].priority < heap[smallest].priority) {
            smallest = leftChild;
        }
        if (rightChild < heap.length && heap[rightChild].priority < heap[smallest].priority) {
            smallest = rightChild;
        }
        if (smallest != index) {
            // Usa una variable temporal para hacer el intercambio en dos pasos
            Task memory temp = heap[index];
            heap[index] = heap[smallest];
            heap[smallest] = temp;

            bubbleDown(smallest);
        }
    }
}
