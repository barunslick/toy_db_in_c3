module row;

import std::io;
import libc;


const int USERNAME_COLUMN_SIZE = 32;
const int EMAIL_COLUMN_SIZE = 255;

struct Row {
	int id;
	char[USERNAME_COLUMN_SIZE] username;
	char[EMAIL_COLUMN_SIZE] email;
}

const uint ID_SIZE = (Row.id).sizeof;
const uint USERNAME_SIZE = (Row.username).sizeof;
const uint EMAIL_SIZE = (Row.email).sizeof;
const uint ID_OFFSET = 0;
const uint USERNAME_OFFSET = ID_OFFSET + ID_SIZE;
const uint EMAIL_OFFSET = USERNAME_OFFSET + USERNAME_SIZE;
const uint ROW_SIZE = ID_SIZE + USERNAME_SIZE + EMAIL_SIZE;

fn void serialize_row(Row* source, void* destination) {
  libc::memcpy(destination + ID_OFFSET, &(source.id), ID_SIZE);
  libc::memcpy(destination + USERNAME_OFFSET, &(source.username), USERNAME_SIZE);
  libc::memcpy(destination + EMAIL_OFFSET, &(source.email), EMAIL_SIZE);
}

fn void deserialize_row(void* source, Row* destination) {
  libc::memcpy(&(destination.id), source + ID_OFFSET, ID_SIZE);
  libc::memcpy(&(destination.username), source + USERNAME_OFFSET, USERNAME_SIZE);
  libc::memcpy(&(destination.email), source + EMAIL_OFFSET, EMAIL_SIZE);
}


fn void print_row(Row* row){
	io::printfn("id: %d, username: %s, email: %s", row.id, row.username, row.email);
}
