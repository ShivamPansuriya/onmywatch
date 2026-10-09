#!/usr/bin/env bash
set -e
mkdir -p shop
cat > shop/catalog.py <<'P'
PRODUCTS = {
    "p1": {"name": "Desk lamp", "price": 30},
    "p2": {"name": "Chair", "price": 120},
    "p7": {"name": "Standing desk", "price": 450},
    "p9": {"name": "Monitor arm", "price": 80},
}

OUT_OF_STOCK = {"p2"}


def can_buy(product_id):
    return product_id in PRODUCTS and product_id not in OUT_OF_STOCK
P
cat > shop/listing.py <<'P'
from shop.catalog import PRODUCTS, can_buy


def listing():
    rows = []
    for pid, p in PRODUCTS.items():
        rows.append({"id": pid, "name": p["name"], "button": "Buy" if can_buy(pid) else "Sold out"})
    return rows
P
cat > shop/cart.py <<'P'
from shop.catalog import PRODUCTS, can_buy


class Cart:
    def __init__(self):
        self.lines = []

    def add(self, product_id, qty=1):
        if not can_buy(product_id):
            raise ValueError(f"{product_id} cannot be bought")
        self.lines.append((product_id, qty))

    def total(self):
        return sum(PRODUCTS[pid]["price"] * qty for pid, qty in self.lines)
P
cat > shop/restock.py <<'P'
from shop.catalog import OUT_OF_STOCK


def restocked(product_id):
    OUT_OF_STOCK.discard(product_id)


def sold_out(product_id):
    OUT_OF_STOCK.add(product_id)
P
touch shop/__init__.py
