import com.sellingticket.dao.EventDAO;
import com.sellingticket.dao.TicketTypeDAO;
import com.sellingticket.model.Event;
import com.sellingticket.model.TicketType;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "TicketSelectionServlet", urlPatterns = {"/tickets"})
public class TicketSelectionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("eventId");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect("events");
            return;
        }
        
        try {
            int eventId = Integer.parseInt(idStr);
            EventDAO eventDAO = new EventDAO();
            TicketTypeDAO ticketTypeDAO = new TicketTypeDAO();
            
            Event event = eventDAO.getEventById(eventId);
            if (event == null) {
                response.sendRedirect("events");
                return;
            }
            
            List<TicketType> ticketTypes = ticketTypeDAO.getTicketTypesByEventId(eventId);
            
            request.setAttribute("event", event);
            request.setAttribute("ticketTypes", ticketTypes);
            request.getRequestDispatcher("ticket-selection.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("events");
        }
    }
}
