<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.json.*" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Order Confirmation</title>
            <link rel="stylesheet" href="css/confirmation.css">
        </head>

        <body>
            <div class="container">
                <h1>Order Confirmation</h1>

                <% Boolean success=(Boolean) request.getAttribute("success"); if (success !=null && success) { String
                    orderDataStr=(String) request.getAttribute("orderData"); JSONObject orderResponse=new
                    JSONObject(orderDataStr); JSONObject order=orderResponse.getJSONObject("order"); Integer
                    pointsAdded=(Integer) request.getAttribute("pointsAdded"); %>

                    <div class="success">
                        <h2>✓ Order Successfully Created!</h2>
                        <p>Your order has been confirmed and you earned <%= pointsAdded %> loyalty points!</p>
                    </div>

                    <div class="order-details">
                        <h3>Order Details</h3>
                        <div class="detail-row">
                            <strong>Order ID:</strong>
                            <span>
                                <%= order.getInt("order_id") %>
                            </span>
                        </div>
                        <div class="detail-row">
                            <strong>Customer ID:</strong>
                            <span>
                                <%= order.getInt("customer_id") %>
                            </span>
                        </div>
                        <div class="detail-row">
                            <strong>Subtotal:</strong>
                            <span>
                                <%= String.format("%.2f", order.getDouble("subtotal")) %> EGP
                            </span>
                        </div>
                        <div class="detail-row">
                            <strong>Tax:</strong>
                            <span>
                                <%= String.format("%.2f", order.getDouble("tax_amount")) %> EGP
                            </span>
                        </div>
                        <div class="detail-row" style="background: #d4edda; font-weight: bold;">
                            <strong>Total:</strong>
                            <span>
                                <%= String.format("%.2f", order.getDouble("total")) %> EGP
                            </span>
                        </div>
                    </div>

                    <% } else { %>

                        <div class="error">
                            <h2>✗ Order Failed</h2>
                            <p>
                                <%= request.getAttribute("error") %>
                            </p>
                        </div>

                        <% } %>

                            <a href="main" class="btn">Back to Main Page</a>
            </div>
        </body>

        </html>