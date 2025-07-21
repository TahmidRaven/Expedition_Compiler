
// ===== scope_table.h =====
#ifndef SCOPE_TABLE_H
#define SCOPE_TABLE_H

#include "symbol_info.h"
#define BUCKET_SIZE 11

class scope_table {
private:
    vector<symbol_info*> table[BUCKET_SIZE];
    int id;

    int hash_function(string key) {
        int sum = 0;
        for (char c : key) sum += c;
        return sum % BUCKET_SIZE;
    }

public:
    scope_table* parent_scope;

    scope_table(int id, scope_table* parent = nullptr) {
        this->id = id;
        parent_scope = parent;
    }

    ~scope_table() {
        for (int i = 0; i < BUCKET_SIZE; ++i) {
            for (auto sym : table[i]) {
                delete sym;
            }
            table[i].clear();
        }
    }

    bool insert(symbol_info* sym) {
        int idx = hash_function(sym->getname());
        for (auto& entry : table[idx]) {
            if (entry->getname() == sym->getname()) return false;
        }
        table[idx].push_back(sym);
        return true;
    }

    symbol_info* lookup(string name) {
        int idx = hash_function(name);
        for (auto& entry : table[idx]) {
            if (entry->getname() == name) return entry;
        }
        return nullptr;
    }

    bool delete_symbol(string name) {
        int idx = hash_function(name);
        for (auto it = table[idx].begin(); it != table[idx].end(); ++it) {
            if ((*it)->getname() == name) {
                delete *it;
                table[idx].erase(it);
                return true;
            }
        }
        return false;
    }

    void print_scope(ofstream& outlog) {
        outlog << "ScopeTable #" << id << endl;
        for (int i = 0; i < BUCKET_SIZE; ++i) {
            if (!table[i].empty()) {
                outlog << i << " --> ";
                for (auto& sym : table[i]) {
                    outlog << "<" << sym->getname() << " : " << sym->gettype() << "> ";
                }
                outlog << endl;
            }
        }
    }

    int get_id() const { return id; }
};

#endif

