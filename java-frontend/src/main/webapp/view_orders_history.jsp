<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.json.*" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Order History</title>
            <link rel="stylesheet" href="css/orders_history.css">
        </head>

        <body>
            <div class="container">
                <h1>Order History</h1>

                <% Boolean success=(Boolean) request.getAttribute("success"); if (success !=null && success) { String
                    ordersJson=(String) request.getAttribute("ordersJson"); JSONObject ordersObj=new
                    JSONObject(ordersJson); JSONArray orders=ordersObj.getJSONArray("orders"); if (orders.length()> 0) {
                    %>

                    <table>
                        <tr>
                            <th>Order ID</th>
                            <th>Subtotal</th>
                            <th>Tax</th>
                            <th>Total</th>
                            <th>Date</th>
                            <th>Action</th>
                        </tr>
                        <% for (int i=0; i < orders.length(); i++) { JSONObject order=orders.getJSONObject(i); %>
                            <tr>
                                <td>
                                    <%= order.getInt("order_id") %>
                                </td>
                                <td>
                                    <%= String.format("%.2f", order.getDouble("subtotal")) %> EGP
                                </td>
                                <td>
                                    <%= String.format("%.2f", order.getDouble("tax_amount")) %> EGP
                                </td>
                                <td><strong>
                                        <%= String.format("%.2f", order.getDouble("total")) %> EGP
                                    </strong></td>
                                <td>
                                    <%= order.getString("created_at") %>
                                </td>
                                <td>
                                    <a href="orderDetails?order_id=<%= order.getInt("order_id") %>" class="btn">Details</a>
                                </td>
                            </tr>
                            <% } %>
                    </table>

                    <% } else { %>

                        <div class="empty">
                            <h3>No orders found</h3>
                            <p>You haven't placed any orders yet.</p>
                        </div>

                        <% } } else { %>

                            <div class="error">
                                <%= request.getAttribute("error") %>
                            </div>

                            <% } %>

                                <a href="main" class="btn">Back to Main</a>
            </div>
        </body>

        </html>