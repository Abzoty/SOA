<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="org.json.JSONObject" %>
        <%@ page import="org.json.JSONArray" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Customer Orders - E-Commerce System</title>
                <link rel="stylesheet" href="css/main.css">
            </head>

            <body>
                <div class="container">
                    <a href="customers" class="back-link">← Back to Customers</a>

                    <h1>Customer Order History</h1>

                    <% String customerJson=(String) request.getAttribute("customerJson"); if (customerJson !=null) {
                        JSONObject customer=new JSONObject(customerJson); %>

                        <div class="customer-info"
                            style="background-color: #f8f9fa; padding: 20px; border-radius: 5px; margin-bottom: 30px;">
                            <h3>Customer Information</h3>
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                                <div>
                                    <strong>Customer ID:</strong>
                                    <%= customer.getInt("customer_id") %>
                                </div>
                                <div>
                                    <strong>Name:</strong>
                                    <%= customer.getString("name") %>
                                </div>
                                <div>
                                    <strong>Email:</strong>
                                    <%= customer.getString("email") %>
                                </div>
                                <div>
                                    <strong>Loyalty Points:</strong>
                                    <%= customer.getInt("loyalty_points") %>
                                </div>
                            </div>
                        </div>

                        <% } Boolean success=(Boolean) request.getAttribute("success"); if (success !=null && success) {
                            String ordersJson=(String) request.getAttribute("ordersJson"); try { JSONObject
                            ordersResponse=new JSONObject(ordersJson); JSONArray orders=null; if
                            (ordersResponse.has("orders")) { Object ordersData=ordersResponse.get("orders"); if
                            (ordersData instanceof JSONArray) { orders=(JSONArray) ordersData; } else if (ordersData
                            instanceof JSONObject) { JSONObject nestedOrders=(JSONObject) ordersData; if
                            (nestedOrders.has("orders")) { orders=nestedOrders.getJSONArray("orders"); } else {
                            orders=new JSONArray(); orders.put(nestedOrders); } } } if (orders !=null &&
                            orders.length()> 0) {
                            %>

                            <h2>Orders (<%= orders.length() %>)</h2>

                            <table>
                                <thead>
                                    <tr>
                                        <th>Order ID</th>
                                        <th>Customer ID</th>
                                        <th>Subtotal (EGP)</th>
                                        <th>Tax Rate (%)</th>
                                        <th>Tax Amount (EGP)</th>
                                        <th>Total (EGP)</th>
                                        <th>Order Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% double totalSpent=0.0; for (int i=0; i < orders.length(); i++) { JSONObject
                                        order=orders.getJSONObject(i); double orderTotal=order.optDouble("total", 0.0);
                                        totalSpent +=orderTotal; %>
                                        <tr>
                                            <td>
                                                <%= order.optInt("order_id", 0) %>
                                            </td>
                                            <td>
                                                <%= order.optInt("customer_id", 0) %>
                                            </td>
                                            <td>
                                                <%= String.format("%.2f", order.optDouble("subtotal", 0.0)) %>
                                            </td>
                                            <td>
                                                <%= String.format("%.2f", order.optDouble("tax_rate", 0.0)) %>
                                            </td>
                                            <td>
                                                <%= String.format("%.2f", order.optDouble("tax_amount", 0.0)) %>
                                            </td>
                                            <td><strong>
                                                    <%= String.format("%.2f", orderTotal) %>
                                                </strong></td>
                                            <td>
                                                <%= order.optString("created_at", "N/A" ) %>
                                            </td>
                                        </tr>
                                        <% } %>
                                            <tr style="background-color: #d4edda; font-weight: bold;">
                                                <td colspan="5" style="text-align: right;">Total Spent:</td>
                                                <td colspan="2">
                                                    <%= String.format("%.2f EGP", totalSpent) %>
                                                </td>
                                            </tr>
                                </tbody>
                            </table>

                            <% } else { %>

                                <div class="alert alert-success">
                                    <strong>No orders found.</strong> This customer hasn't placed any orders yet.
                                </div>

                                <% } } catch (Exception e) { %>

                                    <div class="alert alert-error">
                                        <strong>Error parsing orders:</strong>
                                        <%= e.getMessage() %>
                                            <br><br>
                                            <strong>Raw response:</strong>
                                            <pre
                                                style="background: #f5f5f5; padding: 10px; border-radius: 4px; overflow-x: auto;"><%= ordersJson %></pre>
                                    </div>

                                    <% } } else { String error=(String) request.getAttribute("error"); %>

                                        <div class="alert alert-error">
                                            <strong>Error:</strong>
                                            <%= error !=null ? error : "Failed to fetch orders" %>
                                        </div>

                                        <% } %>

                                            <div class="nav-buttons" style="margin-top: 30px;">
                                                <a href="customers" class="btn btn-primary">Back to Customers</a>
                                                <a href="index.jsp" class="btn btn-secondary">Go to Home</a>
                                            </div>
                </div>
            </body>

            </html>