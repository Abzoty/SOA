<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.json.*" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Customers</title>
            <link rel="stylesheet" href="css/main.css">
        </head>

        <body>
            <div class="container">
                <a href="index.jsp" class="back-link">← Back</a>
                <h1>Customer List</h1>

                <% String json=(String) request.getAttribute("customersJson"); JSONArray customers=new
                    JSONObject(json).getJSONArray("customers"); %>

                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Points</th>
                            <th>Actions</th>
                        </tr>
                        <% for (int i=0; i < customers.length(); i++) { JSONObject c=customers.getJSONObject(i); int
                            id=c.getInt("customer_id"); %>
                            <tr>
                                <td>
                                    <%= id %>
                                </td>
                                <td>
                                    <%= c.getString("name") %>
                                </td>
                                <td>
                                    <%= c.getString("email") %>
                                </td>
                                <td>
                                    <%= c.optString("phone", "-" ) %>
                                </td>
                                <td>
                                    <%= c.getInt("loyalty_points") %>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="updateLoyalty?customer_id=<%= id %>"
                                            class="action-btn btn-update">Points</a>
                                        <a href="customerOrders?customer_id=<%= id %>"
                                            class="action-btn btn-orders">Orders</a>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                    </table>

                    <div class="nav-buttons">
                        <a href="products" class="btn">Products</a>
                        <a href="createOrder" class="btn">Create Order</a>
                    </div>
            </div>
        </body>

        </html>