module toy_db_in_c3;

import std::io;
import libc;

import row;
import table;


enum StatementType {
	STATEMENT_UNKNOWN,
	STATEMENT_SELECT,	
	STATEMENT_INSERT
}

enum MetaCommandResult {
	COMMAND_NOT_FOUND,
	COMMAND_SUCCESS
}

enum ExecuteResult {
	EXECUTE_SUCCESS,
	EXECUTE_FAIL
}

enum PrepareResult {
	PREPARE_SUCCESS,
	PREPARE_FAIL
}

struct Statement {
	StatementType type;
	String args;
}


fn void print_prompt() {io::print("db > ");}

fn MetaCommandResult run_meta_command(String input, Table* table) {
	switch (input) {
		case ".exit": {
			io::printn("Shutting Down..");
			table::free_table(table);
			libc::exit(libc::EXIT_SUCCESS);

		}
		default: return COMMAND_NOT_FOUND;
	}

	return COMMAND_NOT_FOUND;
}


fn ExecuteResult execute_select(Table* table) {
	Row row;
	for (uint i = 0; i < table.num_rows; i++) {
		row::deserialize_row(table::get_row_slot(table, i), &row);
		row::print_row(&row);
	}

	return EXECUTE_SUCCESS;

}

fn ExecuteResult execute_insert(Statement* statement, Table* table){

	String[] args = statement.args.split(" ");

	if (args.len != 3) {
		io::printn("Sorry, our toy db kinda only supports 3 columns as of now.");
		return EXECUTE_FAIL;
	}

	Row row;
	row.id = 1;
	row.username = "abfausn";
	row.email = "sadasd";

	row::serialize_row(&row, table::get_row_slot(table, table.num_rows));
	
	table.num_rows = table.num_rows + 1;

	return EXECUTE_SUCCESS;
		
}

fn ExecuteResult run_statement(Statement* statement, Table* table){
	switch(statement.type) {
		case STATEMENT_SELECT: return execute_select(table);
		case STATEMENT_INSERT: return execute_insert(statement, table);
		default: return EXECUTE_FAIL;
	}	
}

fn PrepareResult prepare_statement(String input, Statement* statement) {
	if (input.len >= 6 && input[:6] == "select") {
		statement.type = STATEMENT_SELECT;
		return PREPARE_SUCCESS;
	}

	if (input.len >= 6 && input[:6] == "insert") {
		statement.type = STATEMENT_INSERT;

		if (input.len == 6) {
			io::printn("Insert Statement requires args.");
			return PREPARE_FAIL;
		}
		statement.args = input[6 .. input.len - 1].trim();

	}
	return PREPARE_SUCCESS;
}

fn int main(String[] args)
{
	Table* table = table::get_new_table();	
	for(;;) {
	  @pool() {
	    print_prompt();
	    String line = io::treadline()!!;
	    if(line[0] == '.') {
		switch(run_meta_command(line, table)) {
			case COMMAND_SUCCESS: continue;
			case COMMAND_NOT_FOUND: continue;
			default: continue;
		}
	    }

	    Statement statement;
	    statement.type = STATEMENT_UNKNOWN;
	    prepare_statement(line, &statement);

	    run_statement(&statement, table);
	    
	    io::printn(statement.type);
	  };
	}
}
