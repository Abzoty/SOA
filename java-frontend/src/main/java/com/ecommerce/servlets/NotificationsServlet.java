package com.ecommerce.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@WebServlet("/notifications")
public class NotificationsServlet extends HttpServlet {

    private static final String NOTIFICATION_SERVICE = "http://localhost:5005/api/notifications/customer";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerId = request.getParameter("customer_id");

        if (customerId == null || customerId.isEmpty()) {
            response.sendRedirect("main");
            return;
        }

        HttpClient client = HttpClient.newHttpClient();

        try {
            HttpRequest notifReq = HttpRequest.newBuilder()
                    .uri(URI.create(NOTIFICATION_SERVICE + "/" + customerId))
                    .GET()
                    .build();

            HttpResponse<String> notifRes = client.send(notifReq, HttpResponse.BodyHandlers.ofString());

            if (notifRes.statusCode() == 200) {
                request.setAttribute("notificationsJson", notifRes.body());
                request.setAttribute("customerId", customerId);
                request.setAttribute("success", true);
            } else {
                request.setAttribute("success", false);
                request.setAttribute("error", "Failed to fetch notifications");
            }

        } catch (Exception e) {
            request.setAttribute("success", false);
            request.setAttribute("error", e.getMessage());
        }

        request.getRequestDispatcher("notifications.jsp").forward(request, response);
    }
}
