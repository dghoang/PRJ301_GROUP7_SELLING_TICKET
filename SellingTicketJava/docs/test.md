
diff --git a/D:\Learning\PRJ\Demo8\JAVA_WEB_PRACTICAL_EXAM_GUIDE.md b/D:\Learning\PRJ\Demo8\JAVA_WEB_PRACTICAL_EXAM_GUIDE.md
new file mode 100644
--- /dev/null
+++ b/D:\Learning\PRJ\Demo8\JAVA_WEB_PRACTICAL_EXAM_GUIDE.md
@@ -0,0 +1,2085 @@
+# Java Web Practical Exam Guide For Demo8
+
+Tai lieu nay duoc viet de ban dung offline trong luc on thi va vao phong thi thuc hanh Java Web.
+Muc tieu la:
+
+- Bam sat project `Demo8` hien tai de ban khong bi doi style code.
+- Tach de thi thanh 3 nhom quen thuoc: `Servlet`, `JSP/JSTL/EL/session`, `JDBC CRUD/search/filter`.
+- Cung cap code mau copy-paste nhanh, sau do chi doi ten field, ten bang, ten class.
+- Giai thich cach doc de, cach nhan dien keyword, thu tu lam bai nhanh nhat.
+
+---
+
+## 1. Project Demo8 dang theo pattern nao
+
+Sau khi doc project, pattern hien tai cua ban la:
+
+- `src/java/controllers`: cac servlet controller.
+- `src/java/dal`: DAO truy van SQL bang JDBC.
+- `src/java/models`: JavaBean model.
+- `web/views`: JSP view.
+- `web/WEB-INF/web.xml`: map servlet bang tay.
+- `web/WEB-INF/ConnectDB.properties`: thong tin ket noi SQL Server.
+- `dal.DBContext`: tao `connection` dung chung.
+
+Flow chinh cua project:
+
+`Browser -> Servlet Controller -> DAO -> Model -> request/session attribute -> JSP`
+
+Pattern dang dung trong Demo8:
+
+```java
+RequestDispatcher rd = request.getRequestDispatcher("views/Students.jsp");
+request.setAttribute("students", students);
+rd.forward(request, response);
+```
+
+Session dang dung trong Demo8:
+
+```java
+HttpSession session = request.getSession();
+session.setAttribute("login", acc);
+```
+
+Kiem tra dang nhap:
+
+```java
+Account loginAccount = (Account) session.getAttribute("login");
+if (loginAccount == null) {
+    response.sendRedirect("Login");
+} else {
+    // xu ly tiep
+}
+```
+
+DAO dang viet theo style:
+
+```java
+String sql = "select * from Students";
+st = connection.prepareStatement(sql);
+rs = st.executeQuery();
+while (rs.next()) {
+    // map resultset -> object
+}
+```
+
+JSP dang dung JSTL/EL:
+
+```jsp
+<c:forEach var="stu" items="${students}">
+    <tr>
+        <td>${stu.getRollNumber()}</td>
+    </tr>
+</c:forEach>
+```
+
+Ket luan quan trong:
+
+- Neu thi gap cau CRUD, ban co the copy style tu `AccountDAO`, `RoleDao`, `StudentsController`, `DetailStudentController`, `Accounts.jsp`, `EditAccount.jsp`.
+- Neu thi gap cau session, ban co the copy cach lay `HttpSession`.
+- Neu thi gap cau select box + table + search, ban co the copy khung tu `AccountsController` va `Accounts.jsp`.
+
+---
+
+## 2. Chien luoc lam bai 3 cau nhanh nhat
+
+### Cau 1
+
+Thuong la:
+
+- `index.html` hoac `index.jsp`
+- form nhap 1, 2 hoac 3 gia tri
+- submit vao 1 servlet
+- validate
+- tinh toan
+- output ra servlet hoac forward lai JSP
+
+### Cau 2
+
+Thuong la:
+
+- `MyExam.jsp`
+- nhap du lieu + 1 hoac nhieu button
+- dung `session` luu danh sach object
+- hien bang bang JSTL
+- co the co check duplicate
+- co the co sort
+- co the co result textfield
+
+### Cau 3
+
+Thuong la:
+
+- load dropdown/select tu bang phu
+- load table tu bang chinh hoac join
+- insert/update/delete/search/filter
+- co radio, checkbox, select
+- phai dung DAO + SQL
+
+### Thu tu lam bai toi uu
+
+1. Doc de, gach chan:
+   - URL truy cap
+   - ten servlet
+   - GET hay POST
+   - ten field input
+   - thong bao loi can in dung y chang de
+   - bang nao can load dau tien
+2. Tao giao dien cho giong hinh truoc.
+3. Tao servlet mapping trong `web.xml`.
+4. Tao model neu cau 2 hoac 3 can.
+5. Viet servlet/DAO xu ly logic.
+6. Forward du lieu len JSP.
+7. Test lai:
+   - input loi
+   - input dung
+   - duplicate
+   - table co them dong moi hay khong
+   - search/filter co dung khong
+
+---
+
+## 3. Ban do de thi va tu khoa can nhin ra ngay
+
+| De ghi | Ban phai nghi ngay |
+|---|---|
+| `access via /index.html` | tao file `web/index.html` hoac `index.jsp` |
+| `servlet is configured in web.xml` | phai them servlet + mapping trong `web.xml` |
+| `using GET method` | form `method="get"` hoac redirect query string |
+| `using POST method` | form `method="post"` |
+| `show error text "..."` | message phai dung y chang |
+| `add result to table` | khong duoc replace dong cu, phai them vao list |
+| `check exist` | duyet list session hoac check DB truoc khi them |
+| `sort` | `Collections.sort(...)` hoac `list.sort(...)` |
+| `load selectbox from table` | can DAO rieng cho bang phu |
+| `load table from join` | viet SQL `join` |
+| `current date` | `Date.valueOf(LocalDate.now())` |
+| `search contains` | SQL `like ?` hoac Java `contains` |
+| `case-insensitive` | `lower(...)` trong SQL hoac `.toLowerCase()` trong Java |
+| `checkbox` | `request.getParameterValues(...)` |
+| `radio` | `request.getParameter(...)` |
+
+---
+
+## 4. Cau 1: Servlet tinh toan va output
+
+Day la dang de de an diem nhanh nhat neu ban co khung co san.
+
+### 4.1. Khung `index.html` hoac `index.jsp` co ban
+
+Neu de bat buoc `index.html`:
+
+```html
+<!DOCTYPE html>
+<html>
+<head>
+    <meta charset="UTF-8">
+    <title>Question 1</title>
+</head>
+<body>
+    <form action="sumPrime" method="post">
+        Enter a: <input type="text" name="a"><br>
+        Enter b: <input type="text" name="b"><br>
+        <input type="submit" value="EXECUTE">
+    </form>
+</body>
+</html>
+```
+
+Neu de cho phep dung `index.jsp` va muon hien message/giu lai du lieu:
+
+```jsp
+<%@page contentType="text/html" pageEncoding="UTF-8"%>
+<!DOCTYPE html>
+<html>
+<head>
+    <meta charset="UTF-8">
+    <title>Question 1</title>
+</head>
+<body>
+    <form action="sumPrime" method="post">
+        Enter a: <input type="text" name="a" value="${param.a}"><br>
+        Enter b: <input type="text" name="b" value="${param.b}"><br>
+        <input type="submit" value="EXECUTE">
+    </form>
+    <div style="color:red">${requestScope.error}</div>
+    <div>${requestScope.result}</div>
+</body>
+</html>
+```
+
+### 4.2. Khung servlet tong quat cho cau 1
+
+```java
+package controllers;
+
+import jakarta.servlet.ServletException;
+import jakarta.servlet.http.HttpServlet;
+import jakarta.servlet.http.HttpServletRequest;
+import jakarta.servlet.http.HttpServletResponse;
+import java.io.IOException;
+import java.io.PrintWriter;
+
+public class SumPrimeServlet extends HttpServlet {
+
+    @Override
+    protected void doPost(HttpServletRequest request, HttpServletResponse response)
+            throws ServletException, IOException {
+        response.setContentType("text/html;charset=UTF-8");
+
+        String aRaw = request.getParameter("a");
+        String bRaw = request.getParameter("b");
+
+        try (PrintWriter out = response.getWriter()) {
+            int a = Integer.parseInt(aRaw);
+            int b = Integer.parseInt(bRaw);
+
+            if (a < 0 || b < 0) {
+                out.print("a and b must be >= 0");
+                return;
+            }
+
+            int result = sumPrimeInRange(a, b);
+            out.print(result);
+        } catch (NumberFormatException e) {
+            response.getWriter().print("Invalid input");
+        }
+    }
+
+    private boolean isPrime(int n) {
+        if (n < 2) return false;
+        for (int i = 2; i * i <= n; i++) {
+            if (n % i == 0) return false;
+        }
+        return true;
+    }
+
+    private int sumPrimeInRange(int a, int b) {
+        int start = Math.min(a, b);
+        int end = Math.max(a, b);
+        int sum = 0;
+        for (int i = start; i <= end; i++) {
+            if (isPrime(i)) sum += i;
+        }
+        return sum;
+    }
+}
+```
+
+### 4.3. Mapping trong `web.xml`
+
+```xml
+<servlet>
+    <servlet-name>SumPrimeServlet</servlet-name>
+    <servlet-class>controllers.SumPrimeServlet</servlet-class>
+</servlet>
+<servlet-mapping>
+    <servlet-name>SumPrimeServlet</servlet-name>
+    <url-pattern>/sumPrime</url-pattern>
+</servlet-mapping>
+```
+
+### 4.4. Mẫu hoan chinh: nhap 2 so a, b va tinh tong so nguyen to trong doan
+
+Neu de bat buoc "output to servlet", dung `PrintWriter`.
+
+Neu de muon giu giao dien, forward lai JSP:
+
+```java
+@Override
+protected void doPost(HttpServletRequest request, HttpServletResponse response)
+        throws ServletException, IOException {
+    String aRaw = request.getParameter("a");
+    String bRaw = request.getParameter("b");
+
+    request.setAttribute("a", aRaw);
+    request.setAttribute("b", bRaw);
+
+    try {
+        int a = Integer.parseInt(aRaw);
+        int b = Integer.parseInt(bRaw);
+
+        int sum = sumPrimeInRange(a, b);
+        request.setAttribute("result", sum);
+    } catch (Exception e) {
+        request.setAttribute("error", "Invalid input");
+    }
+
+    request.getRequestDispatcher("index.jsp").forward(request, response);
+}
+```
+
+### 4.5. Ham dung lai cho cau 1
+
+#### Kiem tra so nguyen to
+
+```java
+private boolean isPrime(int n) {
+    if (n < 2) return false;
+    for (int i = 2; i * i <= n; i++) {
+        if (n % i == 0) return false;
+    }
+    return true;
+}
+```
+
+#### Tong so nguyen to trong doan
+
+```java
+private int sumPrimeInRange(int a, int b) {
+    int start = Math.min(a, b);
+    int end = Math.max(a, b);
+    int sum = 0;
+    for (int i = start; i <= end; i++) {
+        if (isPrime(i)) sum += i;
+    }
+    return sum;
+}
+```
+
+#### Tim tu dai nhat trong chuoi
+
+```java
+private String longestWords(String str) {
+    String[] arr = str.trim().split("\\s+");
+    int max = 0;
+    for (String s : arr) {
+        if (s.length() > max) max = s.length();
+    }
+
+    StringBuilder sb = new StringBuilder();
+    for (String s : arr) {
+        if (s.length() == max) {
+            if (sb.length() > 0) sb.append(", ");
+            sb.append(s);
+        }
+    }
+    return sb.toString();
+}
+```
+
+#### Dem ky tu phu am
+
+```java
+private int countConsonants(String str) {
+    int count = 0;
+    str = str.toLowerCase();
+    for (int i = 0; i < str.length(); i++) {
+        char c = str.charAt(i);
+        if (c >= 'a' && c <= 'z' && "aeiou".indexOf(c) == -1) {
+            count++;
+        }
+    }
+    return count;
+}
+```
+
+#### Boi chung nho nhat cua 2 va 3 so
+
+```java
+private int lcm(int a, int b) {
+    int x = a;
+    int y = b;
+    while (x != y) {
+        if (x < y) x += a;
+        else y += b;
+    }
+    return x;
+}
+
+private int lcm3(int a, int b, int c) {
+    return lcm(lcm(a, b), c);
+}
+```
+
+#### BMI
+
+```java
+private double bmi(double heightCm, double weightKg) {
+    double h = heightCm / 100.0;
+    return weightKg / (h * h);
+}
+
+private String concludeBMI(double bmi) {
+    if (bmi < 18.5) return "Underweight";
+    if (bmi < 25) return "Normal";
+    if (bmi < 30) return "Slightly overweight";
+    return "Obese";
+}
+```
+
+#### Dien tich hinh chu nhat
+
+```java
+private int area(int length, int width) {
+    return length * width;
+}
+```
+
+### 4.6. Mẫu xu ly de "Length of string" va "Consonant characters"
+
+```java
+String str = request.getParameter("str");
+String option = request.getParameter("option");
+
+if (str == null || str.trim().isEmpty()) {
+    response.getWriter().print("Input string is invalid!");
+    return;
+}
+
+if ("Length of string".equals(option)) {
+    response.getWriter().print(str.length());
+} else if ("Consonant characters".equals(option)) {
+    response.getWriter().print(countConsonants(str));
+}
+```
+
+### 4.7. Mẫu validate hay gap
+
+#### So nguyen >= 1
+
+```java
+if (length < 1 || width < 1) {
+    out.print("Both length and width must be an integer number >=1");
+    return;
+}
+```
+
+#### Height/Weight >= 10
+
+```java
+if (height < 10 || weight < 10) {
+    request.setAttribute("error", "Height/Weight must be an integer >=10");
+    request.getRequestDispatcher("MyExam.jsp").forward(request, response);
+    return;
+}
+```
+
+#### Chuoi phai co it nhat 1 khoang trang
+
+```java
+if (str == null || !str.contains(" ")) {
+    out.print("You must input at least a space");
+    return;
+}
+```
+
+---
+
+## 5. Cau 2: JSP + JSTL + EL + Session
+
+Day la dang de cuc ky hay ra.
+
+Tu duy:
+
+- Tao 1 model de luu tung lan thuc hien.
+- Luu `List<Model>` vao `session`.
+- Moi lan bam nut:
+  - doc input
+  - validate
+  - check duplicate neu de yeu cau
+  - tinh toan
+  - them vao list session
+  - sort neu de yeu cau
+  - forward lai `MyExam.jsp`
+
+### 5.1. Khung model chung cho cau 2
+
+Vi du voi de string + option + result:
+
+```java
+package models;
+
+public class ExecutionItem {
+    private String str;
+    private String option;
+    private String result;
+
+    public ExecutionItem() {
+    }
+
+    public ExecutionItem(String str, String option, String result) {
+        this.str = str;
+        this.option = option;
+        this.result = result;
+    }
+
+    public String getStr() {
+        return str;
+    }
+
+    public void setStr(String str) {
+        this.str = str;
+    }
+
+    public String getOption() {
+        return option;
+    }
+
+    public void setOption(String option) {
+        this.option = option;
+    }
+
+    public String getResult() {
+        return result;
+    }
+
+    public void setResult(String result) {
+        this.result = result;
+    }
+}
+```
+
+Vi du voi de BMI:
+
+```java
+package models;
+
+public class BMIRecord {
+    private int height;
+    private int weight;
+    private double bmi;
+    private String conclude;
+
+    public BMIRecord() {
+    }
+
+    public BMIRecord(int height, int weight, double bmi, String conclude) {
+        this.height = height;
+        this.weight = weight;
+        this.bmi = bmi;
+        this.conclude = conclude;
+    }
+
+    public int getHeight() {
+        return height;
+    }
+
+    public int getWeight() {
+        return weight;
+    }
+
+    public double getBmi() {
+        return bmi;
+    }
+
+    public String getConclude() {
+        return conclude;
+    }
+}
+```
+
+### 5.2. Khung `MyExam.jsp` cho de string
+
+```jsp
+<%@page contentType="text/html" pageEncoding="UTF-8"%>
+<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
+<!DOCTYPE html>
+<html>
+<head>
+    <meta charset="UTF-8">
+    <title>MyExam</title>
+</head>
+<body>
+    <form action="StringExam" method="post">
+        Enter a string(str):
+        <input type="text" name="str" value="${requestScope.str}"><br>
+
+        Choose an option:
+        <select name="option">
+            <option value="Consonant characters"
+                ${requestScope.option == 'Consonant characters' ? 'selected' : ''}>
+                Consonant characters
+            </option>
+            <option value="Length of string"
+                ${requestScope.option == 'Length of string' ? 'selected' : ''}>
+                Length of string
+            </option>
+        </select><br>
+
+        Result:
+        <input type="text" readonly value="${requestScope.result}"><br>
+
+        <input type="submit" name="action" value="EXECUTE">
+        <input type="submit" name="action" value="SORT">
+    </form>
+
+    <div style="color:red">${requestScope.error}</div>
+
+    <table border="1">
+        <tr>
+            <th>String str</th>
+            <th>Option</th>
+            <th>Result</th>
+        </tr>
+        <c:forEach var="item" items="${sessionScope.list}">
+            <tr>
+                <td>${item.str}</td>
+                <td>${item.option}</td>
+                <td>${item.result}</td>
+            </tr>
+        </c:forEach>
+    </table>
+</body>
+</html>
+```
+
+### 5.3. Khung servlet cho cau 2 string + duplicate + sort
+
+```java
+package controllers;
+
+import jakarta.servlet.ServletException;
+import jakarta.servlet.http.HttpServlet;
+import jakarta.servlet.http.HttpServletRequest;
+import jakarta.servlet.http.HttpServletResponse;
+import jakarta.servlet.http.HttpSession;
+import java.io.IOException;
+import java.util.ArrayList;
+import java.util.Comparator;
+import java.util.List;
+import models.ExecutionItem;
+
+public class StringExamServlet extends HttpServlet {
+
+    @Override
+    protected void doGet(HttpServletRequest request, HttpServletResponse response)
+            throws ServletException, IOException {
+        request.getRequestDispatcher("MyExam.jsp").forward(request, response);
+    }
+
+    @Override
+    protected void doPost(HttpServletRequest request, HttpServletResponse response)
+            throws ServletException, IOException {
+
+        request.setCharacterEncoding("UTF-8");
+        HttpSession session = request.getSession();
+
+        List<ExecutionItem> list = (List<ExecutionItem>) session.getAttribute("list");
+        if (list == null) {
+            list = new ArrayList<>();
+            session.setAttribute("list", list);
+        }
+
+        String action = request.getParameter("action");
+        String str = request.getParameter("str");
+        String option = request.getParameter("option");
+
+        request.setAttribute("str", str);
+        request.setAttribute("option", option);
+
+        if ("SORT".equals(action)) {
+            list.sort(Comparator.comparing(ExecutionItem::getStr, String.CASE_INSENSITIVE_ORDER));
+            request.getRequestDispatcher("MyExam.jsp").forward(request, response);
+            return;
+        }
+
+        if (str == null || str.trim().isEmpty()) {
+            request.setAttribute("error", "You must input string str");
+            request.getRequestDispatcher("MyExam.jsp").forward(request, response);
+            return;
+        }
+
+        for (ExecutionItem item : list) {
+            if (item.getStr().equalsIgnoreCase(str.trim())
+                    && item.getOption().equals(option)) {
+                request.setAttribute("error", "Execution existed!");
+                request.getRequestDispatcher("MyExam.jsp").forward(request, response);
+                return;
+            }
+        }
+
+        String result;
+        if ("Length of string".equals(option)) {
+            result = String.valueOf(str.length());
+        } else {
+            result = String.valueOf(countConsonants(str));
+        }
+
+        ExecutionItem item = new ExecutionItem(str, option, result);
+        list.add(item);
+
+        request.setAttribute("result", result);
+        request.getRequestDispatcher("MyExam.jsp").forward(request, response);
+    }
+
+    private int countConsonants(String str) {
+        int count = 0;
+        str = str.toLowerCase();
+        for (int i = 0; i < str.length(); i++) {
+            char c = str.charAt(i);
+            if (c >= 'a' && c <= 'z' && "aeiou".indexOf(c) == -1) {
+                count++;
+            }
+        }
+        return count;
+    }
+}
+```
+
+### 5.4. Khung `MyExam.jsp` cho de BMI
+
+```jsp
+<%@page contentType="text/html" pageEncoding="UTF-8"%>
+<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
+<!DOCTYPE html>
+<html>
+<head>
+    <meta charset="UTF-8">
+    <title>BMI</title>
+</head>
+<body>
+    <form action="BMI" method="post">
+        Enter height:
+        <input type="text" name="height" value="${requestScope.height}"> cm<br>
+
+        Enter weight:
+        <input type="text" name="weight" value="${requestScope.weight}"> kg<br>
+
+        <input type="submit" value="BMI">
+        <span style="color:red">${requestScope.error}</span>
+    </form>
+
+    <h3>Body Mass Index (BMI):</h3>
+    <table border="1">
+        <tr>
+            <th>Height</th>
+            <th>Weight</th>
+            <th>BMI</th>
+            <th>Conclude</th>
+        </tr>
+        <c:forEach var="b" items="${sessionScope.bmiList}">
+            <tr>
+                <td>${b.height}</td>
+                <td>${b.weight}</td>
+                <td>${b.bmi}</td>
+                <td>${b.conclude}</td>
+            </tr>
+        </c:forEach>
+    </table>
+</body>
+</html>
+```
+
+### 5.5. Servlet BMI dung session list
+
+```java
+package controllers;
+
+import jakarta.servlet.ServletException;
+import jakarta.servlet.http.HttpServlet;
+import jakarta.servlet.http.HttpServletRequest;
+import jakarta.servlet.http.HttpServletResponse;
+import jakarta.servlet.http.HttpSession;
+import java.io.IOException;
+import java.util.ArrayList;
+import java.util.List;
+import models.BMIRecord;
+
+public class BMIServlet extends HttpServlet {
+
+    @Override
+    protected void doGet(HttpServletRequest request, HttpServletResponse response)
+            throws ServletException, IOException {
+        request.getRequestDispatcher("MyExam.jsp").forward(request, response);
+    }
+
+    @Override
+    protected void doPost(HttpServletRequest request, HttpServletResponse response)
+            throws ServletException, IOException {
+        HttpSession session = request.getSession();
+
+        List<BMIRecord> list = (List<BMIRecord>) session.getAttribute("bmiList");
+        if (list == null) {
+            list = new ArrayList<>();
+            session.setAttribute("bmiList", list);
+        }
+
+        String heightRaw = request.getParameter("height");
+        String weightRaw = request.getParameter("weight");
+
+        request.setAttribute("height", heightRaw);
+        request.setAttribute("weight", weightRaw);
+
+        try {
+            int height = Integer.parseInt(heightRaw);
+            int weight = Integer.parseInt(weightRaw);
+
+            if (height < 10 || weight < 10) {
+                request.setAttribute("error", "Height/Weight must be an integer >=10");
+                request.getRequestDispatcher("MyExam.jsp").forward(request, response);
+                return;
+            }
+
+            double bmi = weight / Math.pow(height / 100.0, 2);
+            bmi = Math.round(bmi * 10.0) / 10.0;
+            String conclude = concludeBMI(bmi);
+
+            list.add(new BMIRecord(height, weight, bmi, conclude));
+            request.getRequestDispatcher("MyExam.jsp").forward(request, response);
+        } catch (Exception e) {
+            request.setAttribute("error", "Height/Weight must be an integer >=10");
+            request.getRequestDispatcher("MyExam.jsp").forward(request, response);
+        }
+    }
+
+    private String concludeBMI(double bmi) {
+        if (bmi < 18.5) return "Underweight";
+        if (bmi < 25) return "Normal";
+        if (bmi < 30) return "Slightly overweight";
+        return "Obese";
+    }
+}
+```
+
+### 5.6. LCM 3 so + duplicate trong session
+
+Neu de giong anh LCM:
+
+- Tao model:
+
+```java
+public class LCMItem {
+    private int a;
+    private int b;
+    private int c;
+    private int result;
+
+    public LCMItem() {
+    }
+
+    public LCMItem(int a, int b, int c, int result) {
+        this.a = a;
+        this.b = b;
+        this.c = c;
+        this.result = result;
+    }
+
+    public int getA() { return a; }
+    public int getB() { return b; }
+    public int getC() { return c; }
+    public int getResult() { return result; }
+}
+```
+
+- Kiem tra duplicate:
+
+```java
+for (LCMItem item : list) {
+    if (item.getA() == a && item.getB() == b && item.getC() == c) {
+        request.setAttribute("error", "Execution existed!");
+        request.getRequestDispatcher("MyExam.jsp").forward(request, response);
+        return;
+    }
+}
+```
+
+- Them vao list:
+
+```java
+int result = lcm3(a, b, c);
+list.add(new LCMItem(a, b, c, result));
+request.setAttribute("result", result);
+```
+
+### 5.7. Checklist cau 2
+
+- Co `@taglib` JSTL chua.
+- Co dung `sessionScope.list` trong bang chua.
+- Co tao list neu `null` chua.
+- Co `check duplicate` neu de yeu cau chua.
+- Co giu lai `str`, `option`, `height`, `weight` sau khi bam nut chua.
+- Co them dong moi vao bang thay vi overwrite chua.
+- Co sort dung theo yeu cau chua.
+
+---
+
+## 6. Cau 3: Database + CRUD + Search + Filter
+
+Day la phan quan trong nhat, nhung Demo8 da co san rat nhieu pattern cho ban copy.
+
+### 6.1. Pattern cua Demo8 ma ban co the dung lai ngay
+
+#### DBContext
+
+Ban giu nguyen tu project:
+
+```java
+public class DBContext {
+    protected Connection connection;
+    public DBContext() {
+        try {
+            Properties properties = new Properties();
+            InputStream inputStream = getClass().getClassLoader()
+                .getResourceAsStream("../ConnectDB.properties");
+            properties.load(inputStream);
+            String user = properties.getProperty("userID");
+            String pass = properties.getProperty("password");
+            String url = properties.getProperty("url");
+            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
+            connection = DriverManager.getConnection(url, user, pass);
+        } catch (Exception ex) {
+            ex.printStackTrace();
+        }
+    }
+}
+```
+
+#### Dropdown bang phu
+
+Tu `RoleDao` cua Demo8:
+
+```java
+public List<Role> getRoles() {
+    List<Role> roles = new ArrayList<>();
+    try {
+        String sql = "select * from Roles";
+        st = connection.prepareStatement(sql);
+        rs = st.executeQuery();
+        while (rs.next()) {
+            int roleId = rs.getInt("roleId");
+            String roleName = rs.getString("roleName");
+            roles.add(new Role(roleId, roleName));
+        }
+    } catch (Exception e) {
+        e.printStackTrace();
+    }
+    return roles;
+}
+```
+
+Khi thi:
+
+- `Roles` co the doi thanh `Types`, `Subjects`, `Positions`, `Users`.
+- `roleId` co the doi thanh `typeId`, `subjectId`, `positionId`, `account`.
+- `roleName` co the doi thanh `typeName`, `subjectName`, `positionName`.
+
+#### Table co join
+
+Tu `AccountDAO.getAccountsWithRole()`:
+
+```java
+String sql = """
+             select a.accountID, a.password, r.roleName
+             from Accounts a
+             join Roles r on a.roleID = r.roleID
+             """;
+```
+
+Mau tong quat:
+
+```java
+String sql = """
+             select e.id, e.str, t.typeName, e.result
+             from Executions e
+             join Types t on e.typeID = t.typeID
+             """;
+```
+
+#### Detail by id
+
+Tu `DetailStudentController` va `StudentDAO.getStudentById`.
+
+#### Create / Update / Delete
+
+Tu `createAccountController`, `EditAccount`, `DeleteAccount`, `AccountDAO`.
+
+### 6.2. Blueprint 5 file cho mot bai CRUD nhanh
+
+Neu de la `Coachs + Positions`, `Posts + Users`, `Instructors + Subjects`, ban thuong can:
+
+1. `ModelChinh.java`
+2. `ModelPhu.java`
+3. `MainDAO.java`
+4. `SubDAO.java`
+5. `MainController.java` hoac nhieu controller `List/Create/Edit/Delete`
+6. `JSP`
+
+Neu de rat ngan, co the dung 1 controller duy nhat xu ly ca `doGet` va `doPost`.
+
+### 6.3. Khung model cho bang dropdown
+
+```java
+package models;
+
+public class Type {
+    private int typeId;
+    private String typeName;
+
+    public Type() {
+    }
+
+    public Type(int typeId, String typeName) {
+        this.typeId = typeId;
+        this.typeName = typeName;
+    }
+
+    public int getTypeId() {
+        return typeId;
+    }
+
+    public void setTypeId(int typeId) {
+        this.typeId = typeId;
+    }
+
+    public String getTypeName() {
+        return typeName;
+    }
+
+    public void setTypeName(String typeName) {
+        this.typeName = typeName;
+    }
+}
+```
+
+### 6.4. Khung model cho bang join de hien table
+
+```java
+package models;
+
+public class ExecutionView {
+    private int id;
+    private String str;
+    private int typeId;
+    private String typeName;
+    private int result;
+
+    public ExecutionView() {
+    }
+
+    public ExecutionView(int id, String str, int typeId, String typeName, int result) {
+        this.id = id;
+        this.str = str;
+        this.typeId = typeId;
+        this.typeName = typeName;
+        this.result = result;
+    }
+
+    public int getId() {
+        return id;
+    }
+
+    public String getStr() {
+        return str;
+    }
+
+    public int getTypeId() {
+        return typeId;
+    }
+
+    public String getTypeName() {
+        return typeName;
+    }
+
+    public int getResult() {
+        return result;
+    }
+}
+```
+
+### 6.5. DAO cho dropdown
+
+```java
+package dal;
+
+import java.sql.PreparedStatement;
+import java.sql.ResultSet;
+import java.util.ArrayList;
+import java.util.List;
+import models.Type;
+
+public class TypeDAO extends DBContext {
+    PreparedStatement st;
+    ResultSet rs;
+
+    public List<Type> getTypes() {
+        List<Type> list = new ArrayList<>();
+        try {
+            String sql = "select * from Types";
+            st = connection.prepareStatement(sql);
+            rs = st.executeQuery();
+            while (rs.next()) {
+                list.add(new Type(
+                        rs.getInt("typeID"),
+                        rs.getString("typeName")
+                ));
+            }
+        } catch (Exception e) {
+            e.printStackTrace();
+        }
+        return list;
+    }
+}
+```
+
+Neu de bat buoc include option `All types`:
+
+- Them option nay trong JSP la nhanh nhat:
+
+```jsp
+<select name="typeId">
+    <option value="all">All types</option>
+    <c:forEach var="t" items="${types}">
+        <option value="${t.typeId}">${t.typeName}</option>
+    </c:forEach>
+</select>
+```
+
+### 6.6. DAO load table co join
+
+```java
+public List<ExecutionView> getExecutions() {
+    List<ExecutionView> list = new ArrayList<>();
+    try {
+        String sql = """
+                     select e.id, e.str, e.typeID, t.typeName, e.result
+                     from Executions e
+                     join Types t on e.typeID = t.typeID
+                     """;
+        st = connection.prepareStatement(sql);
+        rs = st.executeQuery();
+        while (rs.next()) {
+            list.add(new ExecutionView(
+                    rs.getInt("id"),
+                    rs.getString("str"),
+                    rs.getInt("typeID"),
+                    rs.getString("typeName"),
+                    rs.getInt("result")
+            ));
+        }
+    } catch (Exception e) {
+        e.printStackTrace();
+    }
+    return list;
+}
+```
+
+### 6.7. DAO filter theo select
+
+```java
+public List<ExecutionView> filterByType(String typeId) {
+    List<ExecutionView> list = new ArrayList<>();
+    try {
+        String sql = """
+                     select e.id, e.str, e.typeID, t.typeName, e.result
+                     from Executions e
+                     join Types t on e.typeID = t.typeID
+                     where e.typeID = ?
+                     """;
+        st = connection.prepareStatement(sql);
+        st.setInt(1, Integer.parseInt(typeId));
+        rs = st.executeQuery();
+        while (rs.next()) {
+            list.add(new ExecutionView(
+                    rs.getInt("id"),
+                    rs.getString("str"),
+                    rs.getInt("typeID"),
+                    rs.getString("typeName"),
+                    rs.getInt("result")
+            ));
+        }
+    } catch (Exception e) {
+        e.printStackTrace();
+    }
+    return list;
+}
+```
+
+### 6.8. DAO search contains, khong phan biet hoa thuong
+
+```java
+public List<ExecutionView> searchByStr(String keyword) {
+    List<ExecutionView> list = new ArrayList<>();
+    try {
+        String sql = """
+                     select e.id, e.str, e.typeID, t.typeName, e.result
+                     from Executions e
+                     join Types t on e.typeID = t.typeID
+                     where lower(e.str) like ?
+                     """;
+        st = connection.prepareStatement(sql);
+        st.setString(1, "%" + keyword.toLowerCase() + "%");
+        rs = st.executeQuery();
+        while (rs.next()) {
+            list.add(new ExecutionView(
+                    rs.getInt("id"),
+                    rs.getString("str"),
+                    rs.getInt("typeID"),
+                    rs.getString("typeName"),
+                    rs.getInt("result")
+            ));
+        }
+    } catch (Exception e) {
+        e.printStackTrace();
+    }
+    return list;
+}
+```
+
+Neu de ghi: `If TextField is empty, load all information`:
+
+```java
+if (keyword == null || keyword.trim().isEmpty()) {
+    list = dao.getExecutions();
+} else {
+    list = dao.searchByStr(keyword.trim());
+}
+```
+
+### 6.9. DAO insert
+
+```java
+public void insertExecution(String str, int typeId, int result) {
+    try {
+        String sql = """
+                     insert into Executions(str, typeID, result)
+                     values(?, ?, ?)
+                     """;
+        st = connection.prepareStatement(sql);
+        st.setString(1, str);
+        st.setInt(2, typeId);
+        st.setInt(3, result);
+        st.executeUpdate();
+    } catch (Exception e) {
+        e.printStackTrace();
+    }
+}
+```
+
+### 6.10. DAO insert post voi current date
+
+Cho de `Users + Posts`:
+
+```java
+import java.sql.Date;
+import java.time.LocalDate;
+
+public void insertPost(String content, String account) {
+    try {
+        String sql = """
+                     insert into Posts(postContent, account, postDate)
+                     values(?, ?, ?)
+                     """;
+        st = connection.prepareStatement(sql);
+        st.setString(1, content);
+        st.setString(2, account);
+        st.setDate(3, Date.valueOf(LocalDate.now()));
+        st.executeUpdate();
+    } catch (Exception e) {
+        e.printStackTrace();
+    }
+}
+```
+
+### 6.11. Kiem tra password dung selected account
+
+Cho de `Users + Posts`:
+
+```java
+public boolean checkLoginOfSelectedAccount(String account, String password) {
+    try {
+        String sql = "select * from Users where account = ? and password = ?";
+        st = connection.prepareStatement(sql);
+        st.setString(1, account);
+        st.setString(2, password);
+        rs = st.executeQuery();
+        return rs.next();
+    } catch (Exception e) {
+        e.printStackTrace();
+    }
+    return false;
+}
+```
+
+Trong servlet:
+
+```java
+if (!dao.checkLoginOfSelectedAccount(account, password)) {
+    request.setAttribute("error", "Password is wrong");
+    request.setAttribute("users", userDao.getUsers());
+    request.setAttribute("posts", dao.getPosts());
+    request.getRequestDispatcher("PostPage.jsp").forward(request, response);
+    return;
+}
+```
+
+### 6.12. DAO update cho bai Coach
+
+```java
+public void updateCoach(String coachId, String coachName, int expYear,
+        String gender, int positionId) {
+    try {
+        String sql = """
+                     update Coachs
+                     set coachName = ?, expYear = ?, gender = ?, positionID = ?
+                     where coachID = ?
+                     """;
+        st = connection.prepareStatement(sql);
+        st.setString(1, coachName);
+        st.setInt(2, expYear);
+        st.setString(3, gender);
+        st.setInt(4, positionId);
+        st.setString(5, coachId);
+        st.executeUpdate();
+    } catch (Exception e) {
+        e.printStackTrace();
+    }
+}
+```
+
+### 6.13. Servlet tong quat cho list + filter + search
+
+```java
+package controllers;
+
+import dal.ExecutionDAO;
+import dal.TypeDAO;
+import jakarta.servlet.ServletException;
+import jakarta.servlet.http.HttpServlet;
+import jakarta.servlet.http.HttpServletRequest;
+import jakarta.servlet.http.HttpServletResponse;
+import java.io.IOException;
+import java.util.List;
+import models.ExecutionView;
+import models.Type;
+
+public class SearchFilterController extends HttpServlet {
+
+    @Override
+    protected void doGet(HttpServletRequest request, HttpServletResponse response)
+            throws ServletException, IOException {
+        TypeDAO typeDao = new TypeDAO();
+        ExecutionDAO dao = new ExecutionDAO();
+
+        List<Type> types = typeDao.getTypes();
+        List<ExecutionView> list = dao.getExecutions();
+
+        request.setAttribute("types", types);
+        request.setAttribute("list", list);
+        request.getRequestDispatcher("SearchFilter.jsp").forward(request, response);
+    }
+
+    @Override
+    protected void doPost(HttpServletRequest request, HttpServletResponse response)
+            throws ServletException, IOException {
+        TypeDAO typeDao = new TypeDAO();
+        ExecutionDAO dao = new ExecutionDAO();
+
+        String action = request.getParameter("action");
+        String typeId = request.getParameter("typeId");
+        String keyword = request.getParameter("keyword");
+
+        List<Type> types = typeDao.getTypes();
+        List<ExecutionView> list;
+
+        if ("FILTER".equals(action)) {
+            if ("all".equals(typeId)) {
+                list = dao.getExecutions();
+            } else {
+                list = dao.filterByType(typeId);
+            }
+            request.setAttribute("typeId", typeId);
+        } else {
+            if (keyword == null || keyword.trim().isEmpty()) {
+                list = dao.getExecutions();
+            } else {
+                list = dao.searchByStr(keyword.trim());
+            }
+            request.setAttribute("keyword", keyword);
+        }
+
+        request.setAttribute("types", types);
+        request.setAttribute("list", list);
+        request.getRequestDispatcher("SearchFilter.jsp").forward(request, response);
+    }
+}
+```
+
+### 6.14. JSP tong quat cho select + search + table
+
+```jsp
+<%@page contentType="text/html" pageEncoding="UTF-8"%>
+<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
+<!DOCTYPE html>
+<html>
+<head>
+    <meta charset="UTF-8">
+    <title>Search Filter</title>
+</head>
+<body>
+    <form action="search" method="post">
+        Choose an option:
+        <select name="typeId">
+            <option value="all">All types</option>
+            <c:forEach var="t" items="${types}">
+                <option value="${t.typeId}"
+                    ${requestScope.typeId == String.valueOf(t.typeId) ? 'selected' : ''}>
+                    ${t.typeName}
+                </option>
+            </c:forEach>
+        </select>
+        <input type="submit" name="action" value="FILTER"><br>
+
+        Enter a string:
+        <input type="text" name="keyword" value="${requestScope.keyword}">
+        <input type="submit" name="action" value="SEARCH">
+    </form>
+
+    <h3>Result of Filter/Search:</h3>
+    <table border="1">
+        <tr>
+            <th>ID</th>
+            <th>String str</th>
+            <th>Option</th>
+            <th>Result</th>
+        </tr>
+        <c:forEach var="item" items="${list}">
+            <tr>
+                <td>${item.id}</td>
+                <td>${item.str}</td>
+                <td>${item.typeName}</td>
+                <td>${item.result}</td>
+            </tr>
+        </c:forEach>
+    </table>
+</body>
+</html>
+```
+
+### 6.15. JSP radio va checkbox
+
+#### Radio gender
+
+```jsp
+Male <input type="radio" name="gender" value="Male"
+    ${requestScope.gender == 'Male' ? 'checked' : ''}>
+Female <input type="radio" name="gender" value="Female"
+    ${requestScope.gender == 'Female' ? 'checked' : ''}>
+```
+
+#### Checkbox tags
+
+```jsp
+Java <input type="checkbox" name="tags" value="Java">
+Web <input type="checkbox" name="tags" value="Web">
+DB <input type="checkbox" name="tags" value="DB">
+```
+
+Java:
+
+```java
+String[] tags = request.getParameterValues("tags");
+String tagString = "";
+if (tags != null) {
+    tagString = String.join(",", tags);
+}
+```
+
+### 6.16. Mẫu `Create` voi dropdown
+
+```java
+@Override
+protected void doGet(HttpServletRequest request, HttpServletResponse response)
+        throws ServletException, IOException {
+    SubjectDAO sdao = new SubjectDAO();
+    request.setAttribute("subjects", sdao.getSubjects());
+    request.getRequestDispatcher("CreateInstructor.jsp").forward(request, response);
+}
+```
+
+```java
+@Override
+protected void doPost(HttpServletRequest request, HttpServletResponse response)
+        throws ServletException, IOException {
+    String code = request.getParameter("code");
+    String name = request.getParameter("name");
+    String dob = request.getParameter("dob");
+    String gender = request.getParameter("gender");
+    String subjectId = request.getParameter("subjectId");
+
+    InstructorDAO dao = new InstructorDAO();
+    dao.insertInstructor(code, name, dob, gender, Integer.parseInt(subjectId));
+    response.sendRedirect("Instructors");
+}
+```
+
+### 6.17. Mẫu `Update` co select code + hien thong tin
+
+Cho de coach:
+
+```java
+@Override
+protected void doGet(HttpServletRequest request, HttpServletResponse response)
+        throws ServletException, IOException {
+    CoachDAO dao = new CoachDAO();
+    PositionDAO pdao = new PositionDAO();
+
+    String coachId = request.getParameter("coachId");
+
+    request.setAttribute("coaches", dao.getCoachCodes());
+    request.setAttribute("positions", pdao.getPositionsType2());
+
+    if (coachId != null && !coachId.equals("all")) {
+        request.setAttribute("coach", dao.getCoachById(coachId));
+    }
+
+    request.getRequestDispatcher("UpdateCoach.jsp").forward(request, response);
+}
+```
+
+### 6.18. SQL mau cho 4 dang de hay gap
+
+#### Dang 1: Types + Executions
+
+```sql
+create table Types (
+    typeID int primary key,
+    typeName nvarchar(100)
+);
+
+create table Executions (
+    id int identity primary key,
+    str nvarchar(200),
+    typeID int,
+    result int,
+    foreign key (typeID) references Types(typeID)
+);
+```
+
+#### Dang 2: Users + Posts
+
+```sql
+create table Users (
+    account varchar(50) primary key,
+    password varchar(50)
+);
+
+create table Posts (
+    postID int identity primary key,
+    postContent nvarchar(300),
+    account varchar(50),
+    postDate date,
+    foreign key (account) references Users(account)
+);
+```
+
+#### Dang 3: Subjects + Instructors
+
+```sql
+create table Subjects (
+    subjectID int primary key,
+    subjectName nvarchar(100)
+);
+
+create table Instructors (
+    code varchar(20) primary key,
+    name nvarchar(100),
+    dob date,
+    gender varchar(10),
+    subjectID int,
+    foreign key (subjectID) references Subjects(subjectID)
+);
+```
+
+#### Dang 4: Positions + Coachs
+
+```sql
+create table Positions (
+    positionID int primary key,
+    positionName nvarchar(100),
+    type int
+);
+
+create table Coachs (
+    coachID varchar(20) primary key,
+    coachName nvarchar(100),
+    expYear int,
+    gender varchar(10),
+    positionID int,
+    foreign key (positionID) references Positions(positionID)
+);
+```
+
+---
+
+## 7. Mapping tu Demo8 sang de thi de copy nhanh
+
+Dung bang nay khi thi de doi ten class nhanh:
+
+| Trong Demo8 | Khi thi co the doi thanh |
+|---|---|
+| `Account` | `Coach`, `Instructor`, `PostUser`, `Execution` |
+| `Role` | `Position`, `Subject`, `Type` |
+| `AccountDAO` | `CoachDAO`, `InstructorDAO`, `ExecutionDAO`, `PostDAO` |
+| `RoleDao` | `PositionDAO`, `SubjectDAO`, `TypeDAO` |
+| `AccountsController` | `CoachesController`, `InstructorsController`, `SearchFilterController` |
+| `DetailAccountController` | `DetailCoachController`, `DetailInstructorController` |
+| `createAccountController` | `CreateCoachController`, `CreateInstructorController` |
+| `EditAccount` | `UpdateCoachController`, `EditInstructorController` |
+| `DeleteAccount` | `DeleteCoachController`, `DeleteInstructorController` |
+| `Accounts.jsp` | `Coaches.jsp`, `Instructors.jsp`, `SearchFilter.jsp` |
+
+Neu de la CRUD + dropdown + join:
+
+- Copy `RoleDao` -> doi ten bang dropdown.
+- Copy `AccountDAO` -> doi SQL sang bang moi.
+- Copy `AccountsController` -> doi ten DAO/model/view.
+- Copy `createAccountController` / `EditAccount` / `DeleteAccount` -> doi field.
+- Copy `Accounts.jsp` -> doi cot.
+
+---
+
+## 8. Loi de mat diem nhat
+
+### 8.1. Forward nham vao JSP thay vi URL servlet
+
+Trong project Demo8, co nhieu link dang de:
+
+```jsp
+<a href="Accounts.jsp">Exit</a>
+```
+
+Khi thi, uu tien:
+
+```jsp
+<a href="Accounts">Exit</a>
+```
+
+Vi:
+
+- di vao servlet moi load du du lieu
+- vao thang JSP thi co the mat attribute
+
+### 8.2. Truyen parameter sai
+
+Sai:
+
+```java
+st.setString(1, "%+" + "SearchText" + "%");
+```
+
+Dung:
+
+```java
+st.setString(1, "%" + searchText + "%");
+```
+
+### 8.3. Quen set lai attribute sau khi loi
+
+Neu JSP co dropdown:
+
+- khi loi van phai set lai `types`, `subjects`, `positions`
+- neu khong dropdown se rong
+
+### 8.4. Quen tao list session neu null
+
+Sai:
+
+```java
+List<ExecutionItem> list = (List<ExecutionItem>) session.getAttribute("list");
+list.add(item);
+```
+
+Dung:
+
+```java
+List<ExecutionItem> list = (List<ExecutionItem>) session.getAttribute("list");
+if (list == null) {
+    list = new ArrayList<>();
+    session.setAttribute("list", list);
+}
+list.add(item);
+```
+
+### 8.5. Quen giu lai input sau khi submit
+
+Can set:
+
+```java
+request.setAttribute("str", str);
+request.setAttribute("option", option);
+request.setAttribute("height", heightRaw);
+request.setAttribute("weight", weightRaw);
+```
+
+### 8.6. Nhap loi nhung van `parseInt`
+
+Dung:
+
+```java
+try {
+    int a = Integer.parseInt(aRaw);
+} catch (NumberFormatException e) {
+    request.setAttribute("error", "Invalid input");
+}
+```
+
+### 8.7. De yeu cau "add to table" nhung chi thay dong cu
+
+Neu de ghi:
+
+- `add the result to table`
+
+thi phai:
+
+```java
+list.add(newItem);
+```
+
+khong phai:
+
+```java
+list.set(0, newItem);
+```
+
+### 8.8. Quen `method="post"` hoac `method="get"`
+
+De cho gi thi lam dung y chang.
+
+### 8.9. Thong bao loi khong dung y de
+
+Neu de ghi:
+
+`Execution existed!`
+
+thi in dung y chang:
+
+`Execution existed!`
+
+Khong tu sua thanh:
+
+`Execution already existed`
+
+---
+
+## 9. Bo khung file tao nhanh theo tung cau
+
+### 9.1. Cau 1
+
+Ban can:
+
+- `web/index.html` hoac `web/index.jsp`
+- `src/java/controllers/Question1Servlet.java`
+- them mapping vao `web/WEB-INF/web.xml`
+
+### 9.2. Cau 2
+
+Ban can:
+
+- `web/MyExam.jsp`
+- `src/java/models/ExecutionItem.java` hoac `BMIRecord.java`
+- `src/java/controllers/MyExamServlet.java`
+- them mapping vao `web.xml`
+
+### 9.3. Cau 3
+
+Ban can:
+
+- `src/java/models/*.java`
+- `src/java/dal/*.java`
+- `src/java/controllers/*.java`
+- `web/*.jsp` hoac `web/views/*.jsp`
+- mapping `web.xml`
+
+---
+
+## 10. Template `web.xml` dung nhanh
+
+```xml
+<servlet>
+    <servlet-name>MyExamServlet</servlet-name>
+    <servlet-class>controllers.MyExamServlet</servlet-class>
+</servlet>
+<servlet-mapping>
+    <servlet-name>MyExamServlet</servlet-name>
+    <url-pattern>/MyExamServlet</url-pattern>
+</servlet-mapping>
+
+<servlet>
+    <servlet-name>SearchFilterController</servlet-name>
+    <servlet-class>controllers.SearchFilterController</servlet-class>
+</servlet>
+<servlet-mapping>
+    <servlet-name>SearchFilterController</servlet-name>
+    <url-pattern>/search</url-pattern>
+</servlet-mapping>
+```
+
+Neu cau 1 yeu cau:
+
+- `/area`
+- `/max`
+- `/execute`
+- `/bcnn`
+
+thi map dung ten do.
+
+---
+
+## 11. Cach doc de va xu ly tung anh ban gui
+
+### 11.1. Anh dien tich hinh chu nhat
+
+Ban phai lam:
+
+- `index.html`
+- form `length`, `width`
+- submit POST vao `/area`
+- validate `length >= 1 && width >= 1`
+- neu sai in:
+  - `Both length and width must be an integer number >=1`
+- neu dung:
+  - in dien tich ra servlet
+
+### 11.2. Anh BMI
+
+Ban phai lam:
+
+- `MyExam.jsp`
+- input `height`, `weight`
+- button `BMI`
+- dung session luu list BMI
+- validate `height/weight >= 10`
+- tinh BMI
+- ket luan theo 4 muc
+- them dong moi vao table
+
+### 11.3. Anh Posts + Users
+
+Ban phai lam:
+
+- dropdown account load tu `Users`
+- table posts load tu `Posts`
+- khi bam `POST`:
+  - check password co khop selected account khong
+  - neu sai: `Password is wrong`
+  - neu dung: insert post moi, `PostDate = current date`
+
+### 11.4. Anh MAX WORD
+
+Ban phai lam:
+
+- cau 1: string phai co it nhat 1 khoang trang
+- tim tat ca tu dai nhat
+- output ra servlet
+
+### 11.5. Anh MAX WORD + SORT + table
+
+Ban phai lam:
+
+- `MyExam.jsp`
+- result textfield
+- session list
+- duplicate neu de co
+- `MAX WORD` de them vao bang
+- `SORT` de sap xep tang dan theo `str`
+
+### 11.6. Anh Coach update
+
+Ban phai lam:
+
+- dropdown coach code
+- dropdown position theo `type = 2`
+- khi chon coach code:
+  - hien thong tin len form
+- khi bam update:
+  - update DB
+  - hien `Update successfully!`
+
+### 11.7. Anh string + option length/consonant
+
+Ban phai lam:
+
+- cau 1: xu ly bang servlet, in ra servlet
+- cau 2: xu ly bang session va bang ket qua
+- cau 3: luu vao DB va co filter/search
+
+### 11.8. Anh LCM 3 so
+
+Ban phai lam:
+
+- cau 1: tinh LCM 3 so va in ra servlet
+- cau 2: luu session list, duplicate check
+- co ham `lcm(a, b)` roi long them `lcm3`
+
+### 11.9. Anh Instructors + Subjects
+
+Ban phai lam:
+
+- dropdown subject load tu `Subjects`
+- table join hien `SubjectName`
+- form create instructor
+- insert xong reload table
+
+---
+
+## 12. Thu tuc lam bai trong phong thi
+
+### 12.1. 5 phut dau
+
+- Tao interface cho giong hinh.
+- Tao mapping trong `web.xml`.
+- Chay trang cho len giao dien.
+
+### 12.2. 10 phut tiep
+
+- Viet logic servlet hoac DAO.
+- Test bang du lieu mau de dua ra output dung.
+
+### 12.3. 10 phut cuoi
+
+- Test input loi.
+- Test duplicate.
+- Test table co them dong moi.
+- Test search/filter.
+- Doi lai text thong bao cho dung y de.
+
+---
+
+## 13. Phao copy nhanh nhat
+
+### 13.1. Lay parameter
+
+```java
+String str = request.getParameter("str");
+String option = request.getParameter("option");
+String action = request.getParameter("action");
+```
+
+### 13.2. Forward JSP
+
+```java
+request.getRequestDispatcher("MyExam.jsp").forward(request, response);
+```
+
+### 13.3. Redirect ve servlet
+
+```java
+response.sendRedirect("Accounts");
+```
+
+### 13.4. Session list
+
+```java
+HttpSession session = request.getSession();
+List<ExecutionItem> list = (List<ExecutionItem>) session.getAttribute("list");
+if (list == null) {
+    list = new ArrayList<>();
+    session.setAttribute("list", list);
+}
+```
+
+### 13.5. JDBC query co parameter
+
+```java
+String sql = "select * from Executions where lower(str) like ?";
+st = connection.prepareStatement(sql);
+st.setString(1, "%" + keyword.toLowerCase() + "%");
+rs = st.executeQuery();
+```
+
+### 13.6. JDBC insert
+
+```java
+String sql = "insert into Accounts(accountID, password, roleID) values(?, ?, ?)";
+st = connection.prepareStatement(sql);
+st.setString(1, username);
+st.setString(2, password);
+st.setInt(3, roleId);
+st.executeUpdate();
+```
+
+### 13.7. JSTL table
+
+```jsp
+<c:forEach var="item" items="${list}">
+    <tr>
+        <td>${item.id}</td>
+        <td>${item.name}</td>
+    </tr>
+</c:forEach>
+```
+
+### 13.8. JSTL selected option
+
+```jsp
+<option value="${t.typeId}" ${requestScope.typeId == String.valueOf(t.typeId) ? 'selected' : ''}>
+    ${t.typeName}
+</option>
+```
+
+### 13.9. Radio checked
+
+```jsp
+<input type="radio" name="gender" value="Male" ${coach.gender == 'Male' ? 'checked' : ''}>
+```
+
+### 13.10. Date hien tai
+
+```java
+Date.valueOf(LocalDate.now())
+```
+
+---
+
+## 14. Goi y mo rong de ban tu luyen them
+
+Sau khi hoc xong bo nay, tu luyen them cac bien the sau:
+
+- Tong cac so chan trong doan `[a, b]`
+- Tong cac uoc cua `n`
+- Tim chuoi dao nguoc
+- Dem nguyen am / phu am / chu so
+- BMI + duplicate check
+- Sort giam dan thay vi tang dan
+- Search theo 2 dieu kien cung luc
+- Filter theo select + checkbox
+- CRUD co pagination co ban
+- Login + session + logout + phan quyen
+
+---
+
+## 15. Ket luan hoc nhanh
+
+Neu ban nho duoc 3 bo khung sau thi vao thi se rat kho roi:
+
+1. `Form -> Servlet -> Validate -> out.print(...)` cho cau 1.
+2. `MyExam.jsp -> Session List<Model> -> JSTL table` cho cau 2.
+3. `DAO dropdown + DAO join + Controller + JSP select/table + CRUD` cho cau 3.
+
+Hay hoc theo cach:
+
+- Khong hoc tung de rieng le.
+- Hoc theo `pattern`.
+- Thay de moi thi doi:
+  - ten class
+  - ten field
+  - ten bang
+  - text thong bao
+  - cong thuc tinh toan
+
+Ban da co san trong Demo8 nhung mieng ghep rat tot:
+
+- `LoginController`: cach dung session.
+- `StudentsController`: list page.
+- `DetailStudentController`: detail page.
+- `AccountsController`: list + search.
+- `createAccountController`: create.
+- `EditAccount`: update.
+- `DeleteAccount`: delete.
+- `AccountDAO`, `RoleDao`, `StudentDAO`: JDBC template.
+- `Accounts.jsp`, `Students.jsp`, `EditAccount.jsp`: JSP template.
+
+Neu can thao tac nhanh trong phong thi, uu tien:
+
+- copy file gan giong nhat trong Demo8
+- rename class/variable/sql
+- sua text theo de
+- chay tung buoc
+
+Chuc ban on thi hieu qua. Neu ban muon, buoc tiep theo toi uu nhat la tao them cho ban:
+
+- 1 bo `code skeleton` san thanh tung file `.java`/`.jsp`
+- 1 bo `SQL script` luyen 4 dang de
+- 1 bo `10 de mock` giong thi that de ban luyen trong 60 phut
+
