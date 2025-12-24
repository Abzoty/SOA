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

@WebServlet("/orderHistory")
public class OrdersHistoryServlet extends HttpServlet {

    private static final String CUSTOMER_SERVICE = "http://localhost:5004/api/customers";

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
            HttpRequest ordersReq = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE + "/" + customerId + "/orders"))
                    .GET()
                    .build();

            HttpResponse<String> ordersRes = client.send(ordersReq, HttpResponse.BodyHandlers.ofString());

            if (ordersRes.statusCode() == 200) {
                request.setAttribute("ordersJson", ordersRes.body());
                request.setAttribute("customerId", customerId);
                request.setAttribute("success", true);
            } else {
                request.setAttribute("success", false);
                request.setAttribute("error", "Failed to fetch order history");
            }

        } catch (Exception e) {
            request.setAttribute("success", false);
            request.setAttribute("error", e.getMessage());
        }

        request.getRequestDispatcher("view_orders_history.jsp").forward(request, response);
    }
}
