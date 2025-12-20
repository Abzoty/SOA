<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.json.*" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Order Confirmation</title>
            <link rel="stylesheet" href="css/main.css">
            <link rel="stylesheet" href="css/form.css">
        </head>

        <body>
            <div class="container">
                <a href="index.jsp" class="back-link">← Back</a>
                <h1>Order Confirmation</h1>

                <% if ((Boolean) request.getAttribute("success")) { JSONObject order=new JSONObject((String)
                    request.getAttribute("orderData")) .getJSONObject("order"); %>

                    <div class="alert alert-success">
                        <strong>Success!</strong> Order created.
                    </div>

                    <div class="order-details">
                        <h3>Order Details</h3>
                        <div class="order-info">
                            <div><strong>Order ID:</strong>
                                <%= order.getInt("order_id") %>
                            </div>
                            <div><strong>Customer ID:</strong>
                                <%= order.getInt("customer_id") %>
                            </div>
                            <div><strong>Subtotal:</strong>
                                <%= String.format("%.2f EGP", order.getDouble("subtotal")) %>
                            </div>
                            <div><strong>Tax:</strong>
                                <%= String.format("%.2f EGP", order.getDouble("tax_amount")) %>
                            </div>
                            <div style="grid-column: span 2; background-color: #d4edda;">
                                <strong>Total:</strong>
                                <%= String.format("%.2f EGP", order.getDouble("total")) %>
                            </div>
                        </div>
                    </div>

                    <% } else { %>

                        <div class="alert alert-error">
                            <strong>Error:</strong>
                            <%= request.getAttribute("error") %>
                        </div>

                        <% } %>

                            <div class="nav-buttons">
                                <a href="createOrder" class="btn">New Order</a>
                                <a href="customers" class="btn btn-secondary">Customers</a>
                                <a href="products" class="btn btn-secondary">Products</a>
                            </div>
            </div>
        </body>

        </html>