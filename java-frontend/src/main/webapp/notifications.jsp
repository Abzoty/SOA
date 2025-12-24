<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.json.*" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Notifications</title>
            <link rel="stylesheet" href="css/notifications.css">
        </head>

        <body>
            <div class="container">
                <h1>Notifications</h1>

                <% Boolean success=(Boolean) request.getAttribute("success"); if (success !=null && success) { String
                    notificationsJson=(String) request.getAttribute("notificationsJson"); JSONObject notifObj=new
                    JSONObject(notificationsJson); JSONArray notifications=notifObj.getJSONArray("notifications"); if
                    (notifications.length()> 0) {
                    for (int i = 0; i < notifications.length(); i++) { JSONObject notif=notifications.getJSONObject(i);
                        %>

                        <div class="notification">
                            <div class="notification-header">
                                <span class="notification-type">
                                    <%= notif.getString("notification_type").toUpperCase() %>
                                </span>
                                <span class="notification-date">
                                    <%= notif.getString("sent_at") %>
                                </span>
                            </div>
                            <div class="notification-message">
                                Order #<%= notif.getInt("order_id") %>: <%= notif.getString("message") %>
                            </div>
                        </div>

                        <% } } else { %>

                            <div class="empty">
                                <h3>No notifications</h3>
                                <p>You don't have any notifications yet.</p>
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