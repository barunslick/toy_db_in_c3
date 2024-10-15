module btree;

import std::io;

import row;
import constant;


enum NodeType {
	INTERNAL_NODE,
	LEAF_NODE
}

// Commmon Headers for Nodes
// | NODE_TYPE (1 byte) | IS_ROOT (1 byte) | PARENT_POINTER (4 byte) |

const uint NODE_TYPE_SIZE = char.sizeof;
const uint NODE_TYPE_OFFSET = 0;
const uint IS_ROOT_SIZE = char.sizeof;
const uint IS_ROOT_OFFSET = NODE_TYPE_SIZE;
const uint PARENT_POINTER_SIZE = uint.sizeof;
const uint PARENT_POINTER_OFFSET = IS_ROOT_SIZE + IS_ROOT_OFFSET;
const char COMMON_NODE_HEADER_SIZE = NODE_TYPE_SIZE + IS_ROOT_SIZE + PARENT_POINTER_SIZE;


// Leaf Node Header Layout
// | COMMON HEADERS (6 byte) | NUM_OF_CELLS (4 byte) |

const uint NUM_OF_CELLS_SIZE = uint.sizeof;
const uint NUM_OF_CELLS_OFFSET = COMMON_NODE_HEADER_SIZE;
const uint LEAF_NODE_HEADER_SIZE = COMMON_NODE_HEADER_SIZE + NUM_OF_CELLS_SIZE;

// Leaf Node Body Layout
// | CELL (Key, value) (4 bytes + ROW SIZE) |

const uint LEAF_NODE_KEY_SIZE = uint.sizeof;
const uint LEAF_NODE_KEY_OFFSET = LEAF_NODE_HEADER_SIZE;
const uint LEAF_NODE_VALUE_SIZE = row::ROW_SIZE;
const uint LEAF_NODE_VALUE_OFFSET = LEAF_NODE_KEY_SIZE + LEAF_NODE_KEY_OFFSET;

// Size info releated to cells
const uint LEAF_NODE_CELL_SIZE = LEAF_NODE_KEY_SIZE + LEAF_NODE_VALUE_SIZE;
const uint LEAF_NODE_SPACE_FOR_CELLS = constant::PAGE_SIZE - LEAF_NODE_HEADER_SIZE;
const uint MAX_CELLS_PER_NODE = LEAF_NODE_SPACE_FOR_CELLS / LEAF_NODE_CELL_SIZE;

// Helper functions

fn uint* get_num_of_cells_in_node(void* node) {
	return node + NUM_OF_CELLS_OFFSET;
}


fn void* get_leaf_node_cell(void* node, uint cell_num) {
	return node + LEAF_NODE_HEADER_SIZE + cell_num * LEAF_NODE_CELL_SIZE;
}

fn uint* get_leaf_node_cell_key(void* node, uint cell_num) {
	return get_leaf_node_cell(node, cell_num);
}


fn void* get_leaf_node_cell_value(void* node, uint cell_num) {
	return get_leaf_node_cell(node, cell_num) + LEAF_NODE_VALUE_OFFSET;
}

fn void initialize_leaf_node(void* node) {
	*(get_num_of_cells_in_node(node)) = 0;
}


fn void print_constants() {
	io::printn(LEAF_NODE_CELL_SIZE);
	io::printn(LEAF_NODE_SPACE_FOR_CELLS);
	io::printn(LEAF_NODE_HEADER_SIZE);
	io::printn(MAX_CELLS_PER_NODE);
}
