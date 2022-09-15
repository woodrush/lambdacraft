![LambdaCraftLisp's logo](./bin/lambdacraft_logo.png)

LambdaCraft is a Common Lisp DSL for building untyped lambda calculus terms in a macro-based style.
It is inspired by Ben Rudiak-Gould's Scheme program Lazier, a compiler from lambda terms written in Scheme to [Lazy K](https://tromp.github.io/cl/lazy-k.html).
LambdaCraft is used to build [LambdaLisp](https://github.com/woodrush/lambdalisp), a Lisp interpreter written in untyped lambda calculus.

## Example
```sh
(load "./lambdacraft.cl")

(defrec-lazy fact (n)
  (if (<= n 0)
    1
    (* n (fact (- n 1)))))

(format t (compile-to-plaintext-lambda-lazy fact))
```

will print

```
(λx.(λy.(x (y y)) λy.(x (y y))) λx.λy.((((((λz.λa.a λy.λa.λb.(((y λc.λd.(d (c a))) λc.b) λc.c)) y) λz.λz.λb.b) λz.λa.z) λz.λa.(z a)) λz.λa.((y ((x ((λz.λa.(z a) y.λz.λa.(((y λe.λf.(f (e z))) λe.a) λe.e)) y)) z)) a)))
```

Which is a lambda calculus term that takes a [Church-encoded](https://en.wikipedia.org/wiki/Church_encoding) number and returns its factorial.
Here, `defrec-lazy` is a LambdaCraft macro that uses the [Y combinator](https://en.wikipedia.org/wiki/Fixed-point_combinator) for self-recursion.
The source code is available as [example.cl](./example.cl).


## Usage for Lambda-Based Programming Languages
LambdaCraft supports the following lambda-calculus-based and SKI-combinator-based languages:

- [Binary Lambda Calculus](https://tromp.github.io/cl/cl.html)
- [Universal Lambda](http://www.golfscript.com/lam/)
- [Lazy K](https://tromp.github.io/cl/lazy-k.html)

These languages accept a lambda calculus term or a [SKI combinator calculus](https://en.wikipedia.org/wiki/SKI_combinator_calculus) term as a program.
Using a stream-based I/O with strings encoded in the [Mogensen-Scott encoding](https://en.wikipedia.org/wiki/Mogensen%E2%80%93Scott_encoding),
these languages are able to handle lambda terms as a function that takes a string and outputs a string,
where each string represents the standard input and output.

`examples/*.cl` are sample scripts for these languages, which compiles to a program that prints the letter `A` and exits.
The outputs of `examples/*.cl` can be run on each language as:
```sh
sbcl --script ./examples/blc.cl | asc2bin | tromp        # Binary Lambda Calculus
sbcl --script ./examples/ulamb.cl | asc2bin | clamb -u   # Universal Lambda
lazyk <(sbcl --script ./examples/lazyk.cl) -u            # Lazy K
```

Instructions for building the interpreters for these languages are described in detail in my other project, [LambdaLisp](https://github.com/woodrush/lambdalisp).


## Supported Output Formats
LambdaCraft can compile lambda terms into the following formats:

| Format                                                                                                | Example                      | API                                |
|------------------------------------------------------------------------------------------------------ |------------------------------|------------------------------------|
| Plaintext lambda notation                                                                             | `λx.x`                       | `compile-to-plaintext-lambda-lazy` |
| Lisp S-expression                                                                                     | `(lambda (x) x)`             | `compile-to-lisp-lazy`             |
| Lisp S-expression, pretty-printed                                                                     | `(lambda (x) x)`             | `compile-to-lisp-pretty-lazy`      |
| [Binary lambda calculus](https://tromp.github.io/cl/cl.html) notation                                 | `0010`                       | `compile-to-blc-lazy`              |
| SKI combinator calculus term in [Unlambda](http://www.madore.org/~david/programs/unlambda/) notation  | ``` ``skk```                 | `compile-to-ski-lazy`              |
| SKI combinator calculus term                                                                          | `((SK)K)`                    | `compile-to-ski-parens-lazy`       |
| JavaScript function                                                                                   | `function (x) { return x; }` | `compile-to-js-lazy`               |
| JavaScript function in arrow notation                                                                 | `(x) => x`                   | `compile-to-js-arrow-lazy`         |
| Python lambda                                                                                         | `lambda x: x`                | `compile-to-python-lazy`           |


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

LambdaCraft also runs on [LambdaLisp](https://github.com/woodrush/lambdalisp) as well, since it is written as a
Common-Lisp-LambdaLisp polyglot program. Practically, running it on Common Lisp is faster.
