<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.json.*" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>E-Commerce Main</title>
            <link rel="stylesheet" href="css/index.css">
        </head>

        <body>
            <div class="header">
                <div class="user-select">
                    <label>User:</label>
                    <select id="userSelect">
                        <% String customersJson=(String) request.getAttribute("customersJson"); if (customersJson
                            !=null) { JSONArray customers=new JSONObject(customersJson).getJSONArray("customers"); for
                            (int i=0; i < customers.length(); i++) { JSONObject c=customers.getJSONObject(i); int
                            id=c.getInt("customer_id"); String name=c.getString("name"); %>
                            <option value="<%= id %>">
                                <%= id %> - <%= name %>
                            </option>
                            <% }} %>
                    </select>
                </div>
                <div class="nav-buttons">
                    <a href="#" onclick="viewProfile(); return false;" class="btn">View Profile</a>
                    <a href="#" onclick="viewHistory(); return false;" class="btn">View Order History</a>
                    <a href="#" onclick="viewNotifications(); return false;" class="btn">Notifications</a>
                    <a href="health" class="btn btn-secondary">Check Services Health</a>
                </div>
            </div>

            <div class="container content-padding">
                <h1>Available Products</h1>
                <form id="orderForm" action="prepOrder" method="post">
                    <input type="hidden" name="customer_id" id="customerIdField">
                    <div class="product-list">
                        <% String productsJson=(String) request.getAttribute("productsJson"); if (productsJson !=null) {
                            JSONArray products=new JSONObject(productsJson).getJSONArray("products"); for (int i=0; i <
                            products.length(); i++) { JSONObject p=products.getJSONObject(i); int
                            id=p.getInt("product_id"); int maxQty=p.getInt("quantity_available"); %>
                            <div class="product-item">
                                <div class="product-info">
                                    <strong>
                                        <%= p.getString("product_name") %>
                                    </strong><br>
                                    Price: <%= String.format("%.2f", p.getDouble("unit_price")) %> EGP<br>
                                        Available: <%= maxQty %>
                                </div>
                                <div class="product-controls">
                                    <input type="checkbox" class="product-checkbox" data-product-id="<%= id %>"
                                        onchange="toggleQuantity(this, <%= id %>)">
                                    <input type="number" id="qty_<%= id %>" class="qty-input" value="1" min="1"
                                        max="<%= maxQty %>" disabled>
                                </div>
                            </div>
                            <% }} %>
                    </div>
                </form>
            </div>

            <button class="sticky-button" onclick="submitOrder()">Make Order</button>

            <script>
                function toggleQuantity(checkbox, id) {
                    const qtyInput = document.getElementById('qty_' + id);
                    qtyInput.disabled = !checkbox.checked;
                    if (!checkbox.checked) {
                        qtyInput.value = 1;
                    }
                }

                function submitOrder() {
                    const userId = document.getElementById('userSelect').value;
                    if (!userId) {
                        alert('Please select a user');
                        return;
                    }

                    document.getElementById('customerIdField').value = userId;

                    const checkboxes = document.querySelectorAll('.product-checkbox:checked');
                    if (checkboxes.length === 0) {
                        alert('Please select at least one product');
                        return;
                    }

                    const form = document.getElementById('orderForm');

                    const existingHidden = form.querySelectorAll('input[type="hidden"][name="product_id[]"], input[type="hidden"][name="quantity[]"]');
                    existingHidden.forEach(input => input.remove());

                    checkboxes.forEach(checkbox => {
                        const productId = checkbox.getAttribute('data-product-id');
                        const qtyInput = document.getElementById('qty_' + productId);

                        const pidInput = document.createElement('input');
                        pidInput.type = 'hidden';
                        pidInput.name = 'product_id[]';
                        pidInput.value = productId;
                        form.appendChild(pidInput);

                        const qtyHidden = document.createElement('input');
                        qtyHidden.type = 'hidden';
                        qtyHidden.name = 'quantity[]';
                        qtyHidden.value = qtyInput.value;
                        form.appendChild(qtyHidden);
                    });

                    form.submit();
                }

                function viewProfile() {
                        const userId = document.getElementById('userSelect').value;
                        window.location.href = 'profile?customer_id=' + userId;
                    }

                function viewHistory() {
                    const userId = document.getElementById('userSelect').value;
                    window.location.href = 'orderHistory?customer_id=' + userId;
                }

                function viewNotifications() {
                    const userId = document.getElementById('userSelect').value;
                    window.location.href = 'notifications?customer_id=' + userId;
                }
            </script>
        </body>

        </html>