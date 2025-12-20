<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.json.*" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Customer Orders</title>
            <link rel="stylesheet" href="css/main.css">
        </head>

        <body>
            <div class="container">
                <a href="customers" class="back-link">← Back</a>
                <h1>Customer Order History</h1>

                <% JSONObject customer=new JSONObject((String) request.getAttribute("customerJson")); %>

                    <div class="customer-info">
                        <h3>Customer Information</h3>
                        <div>
                            <div><strong>ID:</strong>
                                <%= customer.getInt("customer_id") %>
                            </div>
                            <div><strong>Name:</strong>
                                <%= customer.getString("name") %>
                            </div>
                            <div><strong>Email:</strong>
                                <%= customer.getString("email") %>
                            </div>
                            <div><strong>Points:</strong>
                                <%= customer.getInt("loyalty_points") %>
                            </div>
                        </div>
                    </div>

                    <% JSONObject ordersResponse=new JSONObject((String) request.getAttribute("ordersJson")); JSONObject
                        ordersData=ordersResponse.getJSONObject("orders"); JSONArray
                        orders=ordersData.getJSONArray("orders"); if (orders.length()> 0) {
                        %>

                        <h2>Orders (<%= orders.length() %>)</h2>

                        <table>
                            <tr>
                                <th>Order ID</th>
                                <th>Subtotal</th>
                                <th>Tax</th>
                                <th>Total</th>
                                <th>Date</th>
                            </tr>
                            <% double total=0; for (int i=0; i < orders.length(); i++) { JSONObject
                                o=orders.getJSONObject(i); total +=o.getDouble("total"); %>
                                <tr>
                                    <td>
                                        <%= o.getInt("order_id") %>
                                    </td>
                                    <td>
                                        <%= String.format("%.2f", o.getDouble("subtotal")) %>
                                    </td>
                                    <td>
                                        <%= String.format("%.2f", o.getDouble("tax_amount")) %>
                                    </td>
                                    <td><strong>
                                            <%= String.format("%.2f", o.getDouble("total")) %>
                                        </strong></td>
                                    <td>
                                        <%= o.getString("created_at") %>
                                    </td>
                                </tr>
                                <% } %>
                                    <tr style="background-color: #d4edda; font-weight: bold;">
                                        <td colspan="3" style="text-align: right;">Total Spent:</td>
                                        <td colspan="2">
                                            <%= String.format("%.2f EGP", total) %>
                                        </td>
                                    </tr>
                        </table>

                        <% } else { %>

                            <div class="alert alert-success">No orders found.</div>

                            <% } %>

                                <div class="nav-buttons">
                                    <a href="customers" class="btn">Back to Customers</a>
                                </div>
            </div>
        </body>

        </html>