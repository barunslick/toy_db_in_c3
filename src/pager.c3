module pager;

import libc;
import std::io::file;


const uint PAGE_SIZE = 4096;
const MAX_PAGES_PER_PAGER = 100;

struct Pager {
	File file;
	int file_descriptor;
	uint file_length;
	void*[MAX_PAGES_PER_PAGER] pages;
}


fn Pager* open_pager(String file_name) {

	File file = file::open(file_name, "r+")!!;

	usz file_size = file::get_size(file_name)!!;

	Pager* pager = malloc(Pager.sizeof);
	pager.file = file;
	pager.file_length = (uint)file_size;
	pager.file_descriptor = libc::fileno(file.file);

	io::printn("File INDEXXXXXXXXXX HEREEEEEEEEEEEEEEEEE:");
	io::printn(libc::ftell(file.file));


	for (uint i = 0; i < MAX_PAGES_PER_PAGER; i++) {
		pager.pages[i] = null;
	}

	return pager;
}

fn void* get_page(Pager* pager, int page_num) {
	// Check in Cache if it is present in there
	// Allocate page if they are not present.
	// Bring the page in cache
	// Return page address

	if (page_num > MAX_PAGES_PER_PAGER) {
		io::eprintn("Page number exceeds limit of 100.");
		libc::exit(libc::EXIT_SUCCESS);
	}

	if (pager.pages[page_num] == null) {	//Cache Miss
		io::printn("Cache MISS");
		void* page = malloc(PAGE_SIZE);

		uint current_num_pages = pager.file_length / PAGE_SIZE;

		if(pager.file_length % PAGE_SIZE) {
			current_num_pages += 1;
		}

		if (page_num <= current_num_pages) {
			pager.file.seek((isz)(page_num * PAGE_SIZE))!!;
			//libc::fseek(pager.file.file, (SeekIndex)page_num * PAGE_SIZE, 0);
			libc::read(pager.file_descriptor, page, PAGE_SIZE);

		}

		pager.pages[page_num] = page;
	}

	return pager.pages[page_num];
}
	
fn void pager_flush(Pager* pager, uint page_num, uint size = PAGE_SIZE) {
	if (pager.pages[page_num] == null) {
		io::eprintn("fatal error: cannot flush pages that are empty");
		libc::exit(1);
	}

	pager.file.seek((isz)(page_num * PAGE_SIZE))!!;
	//libc::fseek(pager.file.file, (SeekIndex)page_num * PAGE_SIZE, 0);


	isz bytes_written = libc::write(pager.file_descriptor, pager.pages[page_num], size);

	if (bytes_written == -1) {
		io::eprintn("fatal error: cannot flush page.");
		libc::exit(1);
	}

}

fn void free_pages(Pager* pager) {
	for (uint i = 0; i < MAX_PAGES_PER_PAGER; i++) {
		void* page = pager.pages[i];
		if (page) {
		      free(page);
		      pager.pages[i] = null;
		}
	}
}
