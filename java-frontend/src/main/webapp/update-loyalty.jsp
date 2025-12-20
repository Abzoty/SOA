<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.json.*" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Update Loyalty Points</title>
            <link rel="stylesheet" href="css/main.css">
            <link rel="stylesheet" href="css/form.css">
        </head>

        <body>
            <div class="container">
                <a href="customers" class="back-link">← Back</a>
                <h1>Update Loyalty Points</h1>

                <% String error=request.getParameter("error"); if (error !=null) { %>
                    <div class="alert alert-error">Error updating points</div>
                    <% } %>

                        <% JSONObject customer=new JSONObject((String) request.getAttribute("customerJson")); int
                            id=customer.getInt("customer_id"); %>

                            <div class="customer-info">
                                <h3>Customer Information</h3>
                                <div>
                                    <div><strong>ID:</strong>
                                        <%= id %>
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

                            <form action="updateLoyalty" method="post">
                                <input type="hidden" name="customer_id" value="<%= id %>">

                                <h2>Adjust Points</h2>
                                <div class="form-group">
                                    <label>Points Change</label>
                                    <input type="number" name="points_change" required
                                        placeholder="Positive to add, negative to subtract">
                                </div>

                                <div class="form-actions">
                                    <button type="submit">Update</button>
                                    <a href="customers" class="btn btn-secondary">Cancel</a>
                                </div>
                            </form>
            </div>
        </body>

        </html>