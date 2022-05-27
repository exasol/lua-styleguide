# Lua Style Guide

This style guide covers recommendations for programming in [Lua](https://lua.org).

We tried to stick as closely to established styles as possible.

## Line Width

A line of code has a maximum of 120 characters. Use concatenation where lines overflow. While Lua has no specific hard limit at 120 characters, it nevertheless is a decent compromise between having enough space to avoid forced line breaks most of the time and getting a complete line displayed in most tools and on most displays.

## Character Encoding for Code Files

While Lua can to some extent cope with UTF-8 encoding, you are safer when sticking to ASCII in your source code files. If you need characters outside that range, load the contents from resource files instead of inlining them.

## Line Separator

Independently of filesystem or operating system use Unix line feeds `\n` (ASCII code 10) to separate lines. All modern IDEs can correctly display this, so there is no need for mixing line separators.

## Naming

### Variables and Constants

Variable names are generally lower snake case. As are function-scoped constants.

```lua
local count = 3

function fun()
    local base_url <const> = "http://example.org"
end
```

Module-scoped constants are all-upper snake case.

```lua
my_module = {}

local EULERS_NUMBER <const> = 2.7182818284

return my_module
```

💡 The `<const>` decorator [requires Lua 5.4](http://www.lua.org/manual/5.4/manual.html#3.3.7) or later and is only applicable in combination with the `local` keyword.

Variables that point to [classes](#object-oriented-programming) are written in Upper camel case. Instances of classes are lower snake-case.

```lua
local UrlConverter = require("url.UrlConverter")
local converter_instance = UrlConverter:new()
```

### Function and Method Names

Functions names are treated like variable names, so they are lower-snake case.

💡 While that is a concept that is hard to accept for Lua beginners, strictly speaking functions and methods have no names. It just looks as if they did because functions are first-class objects in Lua and you can assign functions to variables and of course variables have names.

To better illustrate this fact, look at the following examples, which are equivalent.

```lua
function hello() return "hello"  end

-- is the same as saying
hello = function() return "hello"  end
```

There is really no difference, those are just two syntactically valid variants of doing the same thing.

The same is true for module-scoped or object-scoped methods. They are just function objects assigned to table keys (since modules / objects are just Lua tables &mdash; we will get to that later).

```lua
function MyClass.get_version() return "1.2.3" end

-- is equivalent to
MyClass {
    get_version = function() return "1.2.3"  end
}

-- or
MyClass.get_version = function() return "1.2.3" end
```

### Private and Protected Methods

Private and protected methods start with a single underscore, followed by the method name in lower snake-case. We will cover this in more detail in section ["Object-oriented Programming"](#object-oriented-programming).

```lua
function UrlConverter:_init()
    -- intializing converter should not be called from outside the class or a sub-class
end 
```

### The Disposable Variable `_`

In Lua it is an established convention to name a variable that you don't intend to use with a single underscore: `_`

A typical example where this is useful is when you loop over table contents with [`ipairs`](http://www.lua.org/manual/5.4/manual.html#pdf-ipairs), but don't need the index.

```lua
local sum = 0
for _, value in ipairs(my_table) do
    sum = sum + value
end 
```

Using the disposable variable has the advantage that static code analysis tools realize that it is okay if the variable is unused.

Don't mix the `_` variable up with variable names starting with a single underscore. Those traditionally indicate [private methods](#private-and-protected-methods).

### Don't Define Variables Starting with Double Underscores

In Lua Variables prefixed with two underscores are used by the standard library to indicate reserved variables. Take the names of [metamethods](http://www.lua.org/manual/5.4/manual.html#2.4) for example, which all start with a double underscore (e.g. `__add`, `__sub`, `__concat`).

In order to avoid potential conflicts with the standard library, don't define variable names starting with two underscore.

### Module and Class Names

Keep internal module and class consistent with the files they reside in. While it is an often seen standard to simply name modules `M` inside a module file, we recommend writing out the full name. First, that is more self-documenting, second it fits better when defining classes as modules.

You also don't save a lot of time when renaming the module, since modern IDEs can refactor those module and file names with a single command. 

📁  `exasol/ConnectionDefinition.lua` defines class `ConnectionDefinition`

```lua {data-finename="exasol/ConnectionDefinition.lua"}
local ConnectionDefinition = {}

function ConnectionDefinition.new(name, credentials)
    -- create the definition
end

return ConnectionDefinition
```

Usage:

```lua
local ConnectionDefinition = require("exasol.ConnectionDefinition")
local connection = ConnectionDefinition:new("the name", "the credentials")
```

### Avoid Abbreviations

Before we discuss this topic, yes, there are some abbreviations so established that any developer knows them, the most famous of course being the single `i` for an index variable. That being said, code gets more readable if it explicitly says what it does. Compare the following two statements:

```lua
for rank, backlog_item in pairs(backlog_items) do
    -- ...
end 
```

Versus

```lua
for i, b_item in pairs(backlog_items) do
    -- ...
end 
```

Which of those is more readable?

And typing effort is not a valid argument given the auto-completion features of any modern IDE. Even domain abbreviations can be a problem if a reviewer or new code maintainer does not know that domain too well.

```lua
local vin = get_vin()
```

So is it input voltage, a vehicle identification number, video input, a vacancy identification number or a very important notice? Don't make the reviewer guess. Simply spell it out.

To come back to our original acknowledgement, yes, you may use `i` if it stands for "index". But only then.

## Blocks and Continuation Formatting

Blocks are indented by four spaces.

```lua
function hello(language)
    if language == "de" then
        return "Hallo"
    else
        return "hello"
    end
end
```

Statement continuation is indented by eight spaces.

```lua
    local text = "Imagine this was a text that reached the maximum width of a line (120 characters)."
            .. " We indent by eight spaces to distinguish this from block indentation."
```

Put binary operators in front of the continued line in order to make the continuation more obvious.

### Compact Blocks

Keep `then` and `do` on the same line

```lua
if condition then
    -- do something
end

for key, value in pairs(foo) do
    -- do something in a loop
end 
```

While you theoretically can contract trivial blocks into a single line, it is often harder to read them this way. Avoid this kind of contraction unless you really need to conserve vertical space.

## Spaces Inside a Statement

| Rule                                                  | Examples                              |
|-------------------------------------------------------|---------------------------------------|
| Surround binary operators with one space on each side | `foo = "bar"` `result = 1 + 2`        |
| Don't use spaces for unary operators                  | `set_temperatur(-15)`                 |
| Use a single space after a comma                      | `return "foo", "bar", 3`              |
| Don't add spaces before of after round brackets       | `function get_name(id)`               |
| Don't add spaces before of after square brackets      | `operator["plus"] = "+"`              |
| Don't add spaces before of after curly brackets       | `{city = "Rivertown", zip = "12345"}` |

Note that indentation rules take precedence over the rules above.

## Function Parameter Lists

While Lua allows dropping the round brackets in function calls with a single parameter, always use them.

Why?

1. Uniform code is easier to read than mixed code.
2. You immediately see you are dealing with a function call.
3. Parsing is easier should you ever need to search on text level (e.g. with [`grep`](https://www.gnu.org/software/grep/))

```lua
tbl.get_keys({carrot = "red", cucumber = "green"})

-- instead of
tbl.get_keys{carrot = "red", cucumber = "green"}
```

## Formatting Tables

When you construct [Lua tables](http://www.lua.org/manual/5.4/manual.html#3.4.9) you often have to make a tradeoff
between compactness and general readability. The following rules are recommendations. Optimize for readability where
possible.

```lua
local family = {
    parents = {
        {name = "Jane Smith-Doe", age = 42},
        {name = "John Doe", age = 43}
    },
    children = {
        {name = "Juliet Doe", age = 14}
    }
}
```

* Keep the first opening bracket in the same line as the assignment.
* Expand complex structures into multiple lines.
* Contract only the innermost table into one line and only if it is not wider than the [maximum line width](#line-width).
* Indent nested tables by four spaces.

## Comments

We distinguish between two major kinds of using comments:

1. API documentation
2. Explanatory documentation

Use [LDoc](https://stevedonovan.github.io/ldoc/manual/doc.md.html) (the successor of LuaDoc) to document your APIs.

### Code Documentation Language

All comments are written in English. This is the [lingua franca](https://en.wikipedia.org/wiki/Lingua_franca) (pun intended) of all professional programmers around the world. Since we want the code to be readable for the broadest possible developer community, English is the logical choice. Also, if you made it this far into the coding guideline, you should have no problems documenting your code in English. 

### What to Document in the Code

💡 Document your code, don't comment it. Comments are for sports events.

| Situation                                                   | How to document                                                        |
|-------------------------------------------------------------|------------------------------------------------------------------------|
| Public API<br/>(module, function, class, method, constant)  | [LDoc][LDOC]                                                           |
| Complex function                                            | Extract sub-functions and give them speaking names                     |
| Complex module                                              | Extract sub-modules and give them speaking names                       |
| Performance critical algorithm                              | This is a case where an explanation in form of a comment is acceptable |

As you can see from the examples above, there is almost always a better way of documenting your code than commenting it.

The only real exception are algorithms that are so performance-critical that you can't afford splitting them to make them more readable. Only after you checked that this is really necessary, you can add an explanation for the algorithm. Don't forget to justify why splitting it is not an option.

While there are similar flavors to [LDoc][LDOC] (like EmmyDoc) we stick to the original in order to get the broadest tool support.

Check the [LDoc handbook][LDOC] for more information on how to document the different artifacts in your code (functions, modules, classes, fields).

## Scoping

As in any programming language, it is best to keep the scope of all variables as narrow as possible. This prevents accidental corruption in outer scopes and makes [garbage collection](http://www.lua.org/manual/5.4/manual.html#2.5) more efficient.

### Avoid the Global Scope

Avoid the global scope. In Lua the global scope is the top-level scope. You either write to it by leaving out the `local` modifier and module name or by explicitly addressing the reserved `_G` variable. Globals are particular prone to name-collision and overwriting problems.

That being said, there are situations where modifying the global scope actually makes sense. A very typical example is getting forward compatibility in code that has been written for Lua 5.1, but is supposed to run in Lua 5.2 or later too. The following trick maps `table.unpack` to the global scope as was the case prior to Lua 5.2:

```lua
_G.unpack = table.unpack or _G.unpack

-- Old 5.1 code you depend on:
local foo, bar = unpack(the_table)
```

A better option is available when you are in control of the code and don't depend on an external module. In this case you can turn things around to get backward compatibility instead of forward compatibility.

```lua
table.unpack = table.unpack or _G.unpack

-- Old 5.1 code you depend on:
local foo, bar = table.unpack(the_table)
```

In this variant you did not modify the global scope. Instead, you mapped a globally scoped function to the module `table`, which is a lot cleaner.

### Excursion: Extending Existing Lua Modules

As you saw in the example above, you can modify existing Lua Modules, even the ones that come with the standard library. While that looks tempting, use that only with great care, because the library you are modifying might later introduce new features or functions that clash with your modifications.

A popular example of extending a module from the standard library can be found in the [`luassert` library](https://github.com/Olivine-Labs/luassert). Originally [`assert`](http://www.lua.org/manual/5.4/manual.html#pdf-assert) is a function in the Lua standard library. But thanks to Lua's flexibility, you can redefine that as a table and implement lots of nice assertion functions below it, all while keeping the original assertion function intact. Very catchy and nice to read, but bearing the inherent risk of conflict with the language standard.

```lua
assert = require("luassert")

assert.True(true)
assert.is_true(true)
assert.is_not_true(false)
assert.are.equal(1, 1)
assert.has.errors(function() error("this should fail") end)
```

### Module Scope for Functions

It is a good practice in Lua to explicitly use a module scope when loading functions from a module, rather than polluting the global scope.

```lua
local geo = require("exasol.geo")

local point = geo.point(1, 1)
local triangle = geo.polygon({0, 0}, {1, 2}, {2, 0})

geo.is_object_contained_in(point, triangle)
```

Note how the functions are explicitly called with `geo.<function_name>`. While it might be tempting to simply define functions in the global scope, this way is cleaner. Even if it requires a little more typing. In any case, the `geo` variable serves as namespace here and this avoids conflicts with other modules that might define a function called `point`.

## Unit Testing

We recommend the [`busted`](https://olivinelabs.com/busted/) framework for unit testing:

1. Nicely readable internal DSL (i.e. plain old Lua code)
2. Hierarchical test structure
3. Test preparation and clean-up hooks
4. Conditional test execution
5. Nice diagnostics and summary
6. Flexible matchers, thanks to the `luassert` library
7. Stubbing
8. Mocking (at least the part that spies on objects)
9. ... and popular enough to be familiar for most advanced Lua programmers

You can run a test suite simply by issuing the following command

```bash
busted
```

If you [build a LuaRock](#distribution-and-bundling-with-luarocks), a better way is to use the following command, since it abstracts the underlying test framework.

```bash
luarocks --local test
```

## Distribution and Bundling with LuaRocks

Distribute libraries via [LuaRocks](https://luarocks.org/). This is the established way and widely accepted in the Lua community.

You can do this for scripts too, if they are general enough.

### Distributing Virtual Schemas and Other Exasol Lua Scripts

If you make a Lua Virtual Schema for Exasol (i.e. an Adapter Script in Lua), distributing via LuaRocks does not really help you, because the database cannot load from there. so you should use other means like [GitHub](https://github.com) for example.

In the end, users have to install those scripts in the database via an SQL client as inline text.

Also in case of scripts or adapter scripts, you should create bundles that contain all dependencies. We recommend using [`lua-amalg`](https://github.com/siffiejoe/lua-amalg/) for this particular purpose. Note that you cannot use debug-enabled amalg bundles (command line option `-d` or `--debug`) with Exasol, since the debug library was intentionally removed for security purposes.

## Building

If you have a simple build, we recommend using [LuaRock's built-in support for building rocks](https://github.com/luarocks/luarocks/wiki/Creating-a-rock#building-a-module). It can build both pure-Lua and Lua / C mixed packages. In the context of Exasol scripts only pure-lua packages are relevant, since loading binary code is explicitly disabled.

## Object-oriented Programming

... next commit.

[LDOC]: https://github.com/lunarmodules/LDoc