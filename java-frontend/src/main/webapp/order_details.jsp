<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.json.*" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Order Details</title>
            <link rel="stylesheet" href="css/order_details.css">
            <link rel="stylesheet" href="css/profile.css">
        </head>

        <body>
            <div class="container">
                <h1>Order Details</h1>

                <% Boolean success=(Boolean) request.getAttribute("success"); if (success !=null && success) { String
                    orderJson=(String) request.getAttribute("orderJson"); JSONObject order=new JSONObject(orderJson); %>

                    <div class="profile-card">
                        <h3>Order Information</h3>

                        <div class="profile-row">
                            <strong>Order ID:</strong>
                            <span>
                                <%= order.getInt("order_id") %>
                            </span>
                        </div>

                        <div class="profile-row">
                            <strong>Date Placed:</strong>
                            <span>
                                <%= order.optString("created_at", "N/A" ).replace("T", " " ) %>
                            </span>
                        </div>

                        <div class="profile-row">
                            <strong>Customer ID:</strong>
                            <span>
                                <%= order.getInt("customer_id") %>
                            </span>
                        </div>

                        <h3 class="section-header">Items Ordered</h3>

                        <% if (order.has("items") && order.getJSONArray("items").length()> 0) {
                            JSONArray items = order.getJSONArray("items");
                            %>
                            <table class="items-table">
                                <thead>
                                    <tr>
                                        <th>Product ID</th>
                                        <th>Quantity</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (int i=0; i < items.length(); i++) { JSONObject item=items.getJSONObject(i);
                                        %>
                                        <tr>
                                            <td>
                                                <%= item.getInt("product_id") %>
                                            </td>
                                            <td>
                                                <%= item.getInt("quantity") %>
                                            </td>
                                        </tr>
                                        <% } %>
                                </tbody>
                            </table>
                            <% } else { %>
                                <p class="no-items-text">No items found for this order.</p>
                                <% } %>

                                    <h3 class="section-header">Payment Summary</h3>

                                    <div class="profile-row">
                                        <strong>Subtotal:</strong>
                                        <span>$<%= String.format("%.2f", order.getDouble("subtotal")) %></span>
                                    </div>

                                    <div class="profile-row">
                                        <strong>Tax (<%= String.format("%.0f", order.getDouble("tax_rate")) %>
                                                %):</strong>
                                        <span>$<%= String.format("%.2f", order.getDouble("tax_amount")) %></span>
                                    </div>

                                    <div class="profile-row total-row">
                                        <strong>Total Amount:</strong>
                                        <span>$<%= String.format("%.2f", order.getDouble("total")) %></span>
                                    </div>
                    </div>

                    <% } else { %>

                        <div class="error-message">
                            <h3>Error Fetching Order</h3>
                            <p>
                                <%= request.getAttribute("error") !=null ? request.getAttribute("error")
                                    : "Unknown error occurred." %>
                            </p>
                        </div>

                        <% } %>

                            <div class="action-buttons">
                                <a href="main" class="btn btn-primary">Back to Main</a>
                            </div>
            </div>
        </body>

        </html>