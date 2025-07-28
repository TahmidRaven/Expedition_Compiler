#  Expedition Compiler


**For all those who come after.**
*Embark on a journey through syntax and semantics — one token at a time.*


The **Expedition Compiler** is a C-based compiler project built with Lex and Yacc (Flex/Bison), designed for academic and adventurous use. Inspired by the mystery and challenge of fantasy journeys, it parses source code with precision and style.

## ASCII 
```
 _____                         _  _  _    _                 _____                           _  _             
|  ___|                       | |(_)| |  (_)               /  __ \                         (_)| |            
| |__  __  __ _ __    ___   __| | _ | |_  _   ___   _ __   | /  \/  ___   _ __ ___   _ __   _ | |  ___  _ __ 
|  __| \ \/ /| '_ \  / _ \ / _` || || __|| | / _ \ | '_ \  | |     / _ \ | '_ ` _ \ | '_ \ | || | / _ \| '__|
| |___  >  < | |_) ||  __/| (_| || || |_ | || (_) || | | | | \__/\| (_) || | | | | || |_) || || ||  __/| |   
\____/ /_/\_\| .__/  \___| \__,_||_| \__||_| \___/ |_| |_|  \____/ \___/ |_| |_| |_|| .__/ |_||_| \___||_|   
             | |                                                                    | |                      
             |_|                                                                    |_|                      

                                Expedition Compiler – For All Those Who Come After
                                     Created by TahmidRaven & MehediTorno
```
## 🔧 Features

- Lexical analysis with Flex
- Syntax parsing with Bison
- Token and error logging
- Fantasy-themed output structuring
- Modular symbol table system

## 📦 Structure

- `21201701_lex.l`: Lexical analyzer
- `21201701_syn.y`: Syntax parser
- `symbol_info.h`: Symbol table management
- `input/`: Source code samples
- `output/`: Generated logs, parse trees, symbol tables

## 🧙 Lore-Driven Philosophy

> “Not all code that compiles is gold. But this compiler seeks the truth in the syntax.”

> “**When one falls, we continue.** Not *if* — *when*. Because every expedition is built on the courage to rise again.”

> “**For all those who come after.** The path we walk is forged not just for ourselves, but for the future travelers of this language wilderness.”

This compiler is more than a tool — it's a testament. Each token parsed, each rule matched, each bug vanquished is part of an eternal march. We don’t quit. We *compile*.


```
       +------------------+
       |  Source Program  |
       +------------------+
              |
              v
   +------------------------+
   |  Lexical Analysis      | <-- Converts source code into tokens.
   +------------------------+
              |
              v
   +------------------------+
   |  Syntax Analysis       | <-- Builds a parse tree from the tokens.
   +------------------------+
              |
              v
   +------------------------+
   |  Semantic Analysis     | <-- Ensures the program follows language rules (type checking, scope, etc.).
   +------------------------+
              |
              v
   +------------------------+
   |  Intermediate Code     | <-- Converts the parse tree to an intermediate representation (e.g., three-address code).
   +------------------------+
              |
              v
   +------------------------+
   |  Code Optimization     | <-- Improves the intermediate code for better performance or memory usage.
   +------------------------+
              |
              v
   +------------------------+
   |  Code Generation       | <-- Converts the intermediate code into target machine code (assembly or machine code).
   +------------------------+
              |
              v
   +------------------------+
   |  Executable Program    | <-- Final executable code ready for execution.
   +------------------------+

```