<%@ page contentType="text/html;charset=UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <title>Create Order</title>
        <link rel="stylesheet" href="css/main.css">
        <link rel="stylesheet" href="css/form.css">
    </head>

    <body>
        <div class="container">
            <a href="index.jsp" class="back-link">← Back</a>
            <h1>Create New Order</h1>

            <form action="createOrder" method="post">
                <h2>Customer Information</h2>
                <div class="form-group">
                    <label>Customer ID</label>
                    <input type="number" name="customer_id" min="1" required>
                </div>

                <div class="form-group">
                    <label>Region</label>
                    <select name="region">
                        <option value="Cairo">Cairo</option>
                        <option value="Alexandria">Alexandria</option>
                        <option value="Giza">Giza</option>
                    </select>
                </div>

                <h2>Products</h2>
                <div id="products-container">
                    <div class="product-row">
                        <div class="form-group">
                            <label>Product ID</label>
                            <input type="number" name="product_id[]" min="1" required>
                        </div>
                        <div class="form-group">
                            <label>Quantity</label>
                            <input type="number" name="quantity[]" min="1" value="1" required>
                        </div>
                    </div>
                </div>

                <button type="button" class="add-product-btn" onclick="addProductRow()">+ Add Product</button>

                <div class="form-actions">
                    <button type="submit">Submit Order</button>
                </div>
            </form>
        </div>

        <script src="js/order-form.js"></script>
    </body>

    </html>