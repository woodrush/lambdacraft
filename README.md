# LambdaCraft
LambdaCraft is a macro-based Common Lisp DSL for building untyped lambda calculus terms.
It is used to build [LambdaLisp](https://github.com/woodrush/lambdalisp), a Lisp interpreter written in untyped lambda calculus.

A primary use of LambdaCraft is to write programs for lambda-calculus-based programming languages such as
[Binary Lambda Calculus](https://tromp.github.io/cl/cl.html) and
[Universal Lambda](http://www.golfscript.com/lam/).
These languages accept a lambda calculus term as a program.
Using a stream-based I/O with strings encoded in the [Mogensen-Scott encoding](https://en.wikipedia.org/wiki/Mogensen%E2%80%93Scott_encoding),
these languages are able to handle lambda terms as a function that takes a string and outputs a string,
where each string represents the standard input and output.

LambdaCraft can also compile the built lambda term into [SKI combinator calculus](https://en.wikipedia.org/wiki/SKI_combinator_calculus) terms.
With this feature, it can be used to write programs for [Lazy K](https://tromp.github.io/cl/lazy-k.html),
an SKI-combinator-based programming language with the same I/O strategy.

Since LambdaCraft is designed independently from these languages,
it can be used to simply build a general-purpose lambda calculus term.
For example, [example.cl](example.cl) implements the factorial function in lambda calculus.

## Supported Output Formats
LambdaCraft can compile lambda terms into the following formats:

| Format                                                                                                | Example                      | API                                |
|------------------------------------------------------------------------------------------------------ |------------------------------|------------------------------------|
| Plaintext lambda notation                                                                             | `λx.x`                       | `compile-to-plaintext-lambda-lazy` |
| Lisp S-expression                                                                                     | `(lambda (x) x)`             | `compile-to-lisp-lazy`             |
| [Binary lambda calculus](https://tromp.github.io/cl/cl.html) notation                                 | `0010`                       | `compile-to-blc-lazy`              |
| SKI combinator calculus term in [Unlambda](http://www.madore.org/~david/programs/unlambda/) notation  | ``` ``skk```                 | `compile-to-ski-lazy`              |
| SKI combinator calculus term                                                                          | `(SKK)`                      | `compile-to-ski-parens-lazy`       |
| JavaScript function                                                                                   | `function (x) { return x; }` | `compile-to-js-lazy`               |
| JavaScript function in arrow notation                                                                 | `(x) => x`                   | `compile-to-js-arrow-lazy`         |
| Python lambda                                                                                         | `lambda x: x`                | `compile-to-python-lambda-lazy`    |


## Usage
LambdaCraft is written in Common Lisp. It should run in any Common Lisp interpreter of your choice.
I particularly use SBCL (Steel Bank Common Lisp), which is installable by:

```sh
sudo apt install sbcl
```

or on a Mac with:
```sh
brew install sbcl
```

LambdaCraft can then be used by simply including the program as a header,
and running the source as a Common Lisp program.
For example, [example.cl](example.cl) can be run as:

```sh
sbcl --script example.cl
```

which will print the factorial function defined in the script.
