let productCount = 1;

function addProductRow() {
    productCount++;
    const container = document.getElementById('products-container');
    const newRow = document.createElement('div');
    newRow.className = 'product-row';
    newRow.id = 'product-row-' + productCount;

    newRow.innerHTML = `
        <div class="form-group">
            <label for="product_id_${productCount}">Product ID</label>
            <input type="number" name="product_id[]" id="product_id_${productCount}" 
                    min="1" required>
        </div>
        <div class="form-group">
            <label for="quantity_${productCount}">Quantity</label>
            <input type="number" name="quantity[]" id="quantity_${productCount}" 
                    min="1" value="1" required>
        </div>
        <button type="button" onclick="removeProductRow(${productCount})">Remove</button>
    `;

    container.appendChild(newRow);
}

function removeProductRow(rowId) {
    const row = document.getElementById('product-row-' + rowId);
    if (row) {
        row.remove();
    }
}