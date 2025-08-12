#ifndef SYMBOL_INFO_H
#define SYMBOL_INFO_H

#include <bits/stdc++.h>
using namespace std;

class symbol_info {
private:
    string sym_name;
    string sym_type;

public:
    symbol_info() {}
    
    symbol_info(string name, string type) {
        sym_name = name;
        sym_type = type;
    }

    string getname() {
        return sym_name;
    }

    string gettype() {
        return sym_type;
    }

    void setname(string name) {
        sym_name = name;
    }

    void settype(string type) {
        sym_type = type;
    }
};

#endif