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
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/prepOrder")
public class PrepOrderServlet extends HttpServlet {

    private static final String INVENTORY_SERVICE = "http://localhost:5002/api/inventory/check";
    private static final String PRICING_SERVICE = "http://localhost:5003/api/pricing/calculate";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerId = request.getParameter("customer_id");
        String[] productIds = request.getParameterValues("product_id[]");
        String[] quantities = request.getParameterValues("quantity[]");

        if (customerId == null || productIds == null || quantities == null) {
            request.setAttribute("error", "Missing required fields");
            request.getRequestDispatcher("main").forward(request, response);
            return;
        }

        HttpClient client = HttpClient.newHttpClient();
        JSONArray validatedProducts = new JSONArray();

        try {
            for (int i = 0; i < productIds.length; i++) {
                if (productIds[i] == null || productIds[i].isEmpty())
                    continue;

                int productId = Integer.parseInt(productIds[i]);
                int requestedQty = Integer.parseInt(quantities[i]);

                HttpRequest invReq = HttpRequest.newBuilder()
                        .uri(URI.create(INVENTORY_SERVICE + "/" + productId))
                        .GET()
                        .build();

                HttpResponse<String> invRes = client.send(invReq, HttpResponse.BodyHandlers.ofString());

                if (invRes.statusCode() == 200) {
                    JSONObject product = new JSONObject(invRes.body());
                    int availableQty = product.getInt("quantity_available");

                    if (availableQty > 0) {
                        int finalQty = Math.min(requestedQty, availableQty);

                        JSONObject validProduct = new JSONObject();
                        validProduct.put("product_id", productId);
                        validProduct.put("quantity", finalQty);
                        validProduct.put("unit_price", product.getDouble("unit_price"));
                        validProduct.put("product_name", product.getString("product_name"));
                        validatedProducts.put(validProduct);
                    }
                }
            }

            if (validatedProducts.length() == 0) {
                request.setAttribute("error", "No valid products available");
                request.getRequestDispatcher("main").forward(request, response);
                return;
            }

            JSONObject pricingPayload = new JSONObject();
            pricingPayload.put("products", validatedProducts);
            pricingPayload.put("region", "Cairo");

            HttpRequest pricingReq = HttpRequest.newBuilder()
                    .uri(URI.create(PRICING_SERVICE))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(pricingPayload.toString()))
                    .build();

            HttpResponse<String> pricingRes = client.send(pricingReq, HttpResponse.BodyHandlers.ofString());

            if (pricingRes.statusCode() == 200) {
                JSONObject pricingData = new JSONObject(pricingRes.body());
                request.setAttribute("customerId", customerId);
                request.setAttribute("pricingData", pricingData.toString());
                request.getRequestDispatcher("checkout.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Pricing calculation failed");
                request.getRequestDispatcher("main").forward(request, response);
            }

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("main").forward(request, response);
        }
    }
}