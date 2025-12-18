<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="org.json.JSONObject" %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Order Confirmation - E-Commerce System</title>
            <link rel="stylesheet" href="css/main.css">
            <link rel="stylesheet" href="css/form.css">
        </head>

        <body>
            <div class="container">
                <a href="index.jsp" class="back-link">← Back to Home</a>

                <h1>Order Confirmation</h1>

                <% Boolean success=(Boolean) request.getAttribute("success"); if (success !=null && success) { 
                    String orderData=(String) request.getAttribute("orderData");
                    JSONObject jsonResponse=new JSONObject(orderData); 
                    JSONObject order=jsonResponse.getJSONObject("order"); %>

                    <div class="alert alert-success">
                        <strong>Success!</strong> Your order has been created successfully.
                    </div>

                    <div class="order-details">
                        <h3>Order Details</h3>
                        <div class="order-info">
                            <div>
                                <strong>Order ID:</strong>
                                <%= order.getInt("order_id") %>
                            </div>
                            <div>
                                <strong>Customer ID:</strong>
                                <%= order.getInt("customer_id") %>
                            </div>
                            <div>
                                <strong>Created At:</strong>
                                <%= order.getString("created_at") %>
                            </div>
                            <div>
                                <strong>Subtotal:</strong>
                                <%= String.format("%.2f EGP", order.getDouble("subtotal")) %>
                            </div>
                            <div>
                                <strong>Tax Rate:</strong>
                                <%= String.format("%.2f", order.getDouble("tax_rate")) %>
                            </div>
                            <div>
                                <strong>Tax Amount:</strong>
                                <%= String.format("%.2f EGP", order.getDouble("tax_amount")) %>
                            </div>
                            <div style="grid-column: span 2; background-color: #d4edda; font-size: 1.2em;">
                                <strong>Total:</strong>
                                <%= String.format("%.2f EGP", order.getDouble("total")) %>
                            </div>
                        </div>

                        <p style="margin-top: 15px; color: #666;">
                            A confirmation email has been sent to the customer's registered email address.
                        </p>
                    </div>

                    <% } else { String error=(String) request.getAttribute("error"); %>

                        <div class="alert alert-error">
                            <strong>Error:</strong>
                            <%= error !=null ? error : "Unknown error occurred while creating the order" %>
                        </div>

                        <p style="margin-top: 20px;">
                            Please check the following:
                        </p>
                        <ul style="margin-left: 20px; color: #666;">
                            <li>Customer ID exists in the system</li>
                            <li>Product IDs are valid</li>
                            <li>Products have sufficient stock</li>
                            <li>All microservices are running</li>
                        </ul>

                        <% } %>

                            <div class="nav-buttons" style="margin-top: 30px;">
                                <a href="createOrder" class="btn btn-primary">Create Another Order</a>
                                <a href="customers" class="btn btn-secondary">View Customers</a>
                                <a href="products" class="btn btn-secondary">View Products</a>
                            </div>
            </div>
        </body>

        </html>