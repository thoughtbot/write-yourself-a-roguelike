# Building

There is a build tool included with this project that will allow you to compile the contents of the `book` directory into an EPUB-formatted e-book. First, to ensure that you’ve got the necessary dependencies for the compilation process, change to the project directory and run:

    $ bundle install

We then need to have [Pandoc](http://pandoc.org/installing.html) installed.

Now, anytime you’d like to compile the book you can simply run the compile script:

    $ exe/compile

Doing so will write a file entitled `write-yourself-a-roguelike.epub` to the `release` directory, overwriting any existing file with the same name.
