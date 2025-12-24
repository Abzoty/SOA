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

@WebServlet("/orderDetails")
public class OrderDetailsServlet extends HttpServlet {

    private static final String ORDER_SERVICE = "http://localhost:5001/api/orders";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String orderId = request.getParameter("order_id");

        if (orderId == null || orderId.isEmpty()) {
            response.sendRedirect("main");
            return;
        }

        HttpClient client = HttpClient.newHttpClient();

        try {
            HttpRequest orderReq = HttpRequest.newBuilder()
                    .uri(URI.create(ORDER_SERVICE + "/" + orderId))
                    .GET()
                    .build();

            HttpResponse<String> orderRes = client.send(orderReq, HttpResponse.BodyHandlers.ofString());

            if (orderRes.statusCode() == 200) {
                request.setAttribute("orderJson", orderRes.body());
                request.setAttribute("success", true);
            } else {
                request.setAttribute("success", false);
                request.setAttribute("error", "Failed to fetch order details");
            }

        } catch (Exception e) {
            request.setAttribute("success", false);
            request.setAttribute("error", e.getMessage());
        }

        request.getRequestDispatcher("order_details.jsp").forward(request, response);
    }
}
