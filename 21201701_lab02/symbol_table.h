
// ===== symbol_table.h =====
#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include "scope_table.h"

class symbol_table {
private:
    scope_table* current;
    int scope_counter = 1;

public:
    symbol_table() {
        current = new scope_table(scope_counter);
    }

    ~symbol_table() {
        while (current != nullptr) {
            scope_table* temp = current;
            current = current->parent_scope;
            delete temp;
        }
    }

    void enter_scope() {
        scope_counter++;
        scope_table* new_scope = new scope_table(scope_counter, current);
        current = new_scope;
    }

    void exit_scope(ofstream& outlog) {
        if (current == nullptr) return;
        outlog << "ScopeTable with id " << current->get_id() << " removed" << endl;
        scope_table* temp = current;
        current = current->parent_scope;
        delete temp;
    }

    bool insert(symbol_info* sym) {
        if (current == nullptr) return false;
        return current->insert(sym);
    }

    bool remove(string name) {
        if (current == nullptr) return false;
        return current->delete_symbol(name);
    }

    symbol_info* lookup(string name) {
        scope_table* temp = current;
        while (temp != nullptr) {
            symbol_info* sym = temp->lookup(name);
            if (sym) return sym;
            temp = temp->parent_scope;
        }
        return nullptr;
    }

    void print_current_scope(ofstream& outlog) {
        if (current != nullptr) current->print_scope(outlog);
    }

    void print_all_scopes(ofstream& outlog) {
        scope_table* temp = current;
        while (temp != nullptr) {
            temp->print_scope(outlog);
            temp = temp->parent_scope;
        }
    }
};

#endif
// ===== End of symbol_table.h =====