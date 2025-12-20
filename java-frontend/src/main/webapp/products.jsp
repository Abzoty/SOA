<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.json.*" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Products</title>
            <link rel="stylesheet" href="css/main.css">
        </head>

        <body>
            <div class="container">
                <a href="index.jsp" class="back-link">← Back</a>
                <h1>Product Inventory</h1>

                <% String json=(String) request.getAttribute("productsJson"); JSONArray products=new
                    JSONObject(json).getJSONArray("products"); %>

                    <table>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Price</th>
                            <th>Stock</th>
                        </tr>
                        <% for (int i=0; i < products.length(); i++) { JSONObject p=products.getJSONObject(i); %>
                            <tr>
                                <td>
                                    <%= p.getInt("product_id") %>
                                </td>
                                <td>
                                    <%= p.getString("product_name") %>
                                </td>
                                <td>
                                    <%= String.format("%.2f EGP", p.getDouble("unit_price")) %>
                                </td>
                                <td>
                                    <%= p.getInt("quantity_available") %>
                                </td>
                            </tr>
                            <% } %>
                    </table>

                    <div class="nav-buttons">
                        <a href="customers" class="btn">Customers</a>
                        <a href="createOrder" class="btn">Create Order</a>
                    </div>
            </div>
        </body>

        </html>