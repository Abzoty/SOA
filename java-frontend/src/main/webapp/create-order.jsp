<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Create Order - E-Commerce System</title>
        <link rel="stylesheet" href="css/main.css">
        <link rel="stylesheet" href="css/form.css">
    </head>

    <body>
        <div class="container">
            <a href="index.jsp" class="back-link">← Back to Home</a>

            <h1>Create New Order</h1>

            <form id="order-form" action="createOrder" method="post">
                <!-- Customer Information -->
                <h2>Customer Information</h2>
                <div class="form-group">
                    <label for="customer_id">Customer ID *</label>
                    <input type="number" id="customer_id" name="customer_id" min="1" required>
                </div>

                <div class="form-group">
                    <label for="region">Region</label>
                    <select id="region" name="region">
                        <option value="Cairo">Cairo</option>
                        <option value="Alexandria">Alexandria</option>
                        <option value="Giza">Giza</option>
                    </select>
                </div>

                <!-- Products Section -->
                <h2>Products</h2>
                <div id="products-container">
                    <div class="product-row" id="product-row-1">
                        <div class="form-group">
                            <label for="product_id_1">Product ID *</label>
                            <input type="number" name="product_id[]" id="product_id_1" min="1" required
                                placeholder="Enter product ID">
                        </div>
                        <div class="form-group">
                            <label for="quantity_1">Quantity *</label>
                            <input type="number" name="quantity[]" id="quantity_1" min="1" value="1" required>
                        </div>
                    </div>
                </div>

                <button type="button" class="add-product-btn" onclick="addProductRow()">
                    + Add Another Product
                </button>

                <!-- Form Actions -->
                <div class="form-actions">
                    <button type="submit">Submit Order</button>
                </div>
            </form>

        <script src="js/order-form.js"></script>
    </body>

    </html>