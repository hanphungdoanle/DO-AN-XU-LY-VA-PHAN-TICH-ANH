Đồ án tập trung ứng dụng các kỹ thuật xử lý ảnh để khôi phục ảnh bị suy biến do nhiễu (noise) và nhòe (blur). Tích hợp 6 thuật toán (Lọc trung vị (Median filter) Lấy trung bình ảnh(Image averaging), Lowpass filtering/Box&Gausian filtering), Lọc inverse (iFFT), Lọc Wiener Filtering).

##Tên đề tài
Ứng dụng các kĩ thuật xử lý ảnh để giải quyết các vấn đề liên quan đến nhiễu và nhòe.

##Mục tiêu dự án

Dự án tập trung xây dựng một ứng dụng trực quan trên nền tảng Web nhằm tích hợp 6 thuật toán xử lý ảnh, giúp người dùng quan sát quá trình suy biến của ảnh và đánh giá hiệu quả của các phương pháp khôi phục (khử nhiễu và khử nhòe).

##Công nghệ và Thư viện sử dụng
- Ngôn ngữ lập trình: Python.
- Thư viện thuật toán lõi: NumPy (xử lý tính toán ma trận), SciPy (toán học và biến đổi Fourier), OpenCV (đọc, xuất và chuyển đổi ảnh).
- Xây dựng Giao diện (GUI): Streamlit (framework tạo Web app nhanh chóng bằng Python).

##Các tính năng và Luồng xử lý chính
Hệ thống được thiết kế với các module chức năng chi tiết như sau:

- Tương tác trực quan:
+Ứng dụng cho phép người dùng upload ảnh, hệ thống sẽ đọc và tự động chuyển đổi từ hệ màu RGB sang ảnh xám (Grayscale).
+Web App sử dụng cấu trúc chia cột để hiển thị song song đối chiếu: ảnh gốc, ảnh suy biến và ảnh sau khôi phục.

- Mô phỏng suy biến ảnh: Tính năng chủ động đưa các tác nhân làm hỏng ảnh vào ảnh gốc để làm dữ liệu thử nghiệm, bao gồm:
+Tạo nhiễu Gaussian (Phân bố chuẩn).
+Tạo nhiễu Salt & Pepper (Muối tiêu).
+Tạo hiệu ứng nhòe Motion Blur bằng phép chập ma trận (Convolution).

- Tích hợp 6 Thuật toán Khôi phục ảnh:
+Xử lý nhiễu (Miền không gian):Sử dụng các kỹ thuật Lọc trung bình (Box/Averaging Filter), Lọc Gaussian, và Lọc trung vị (Median Filter).
+Xử lý nhòe (Miền tần số): Chuyển đổi ảnh sang miền tần số bằng Fourier 2D (FFT2) để áp dụng thuật toán Lọc ngược (Inverse Filtering) và Lọc Wiener.

- Tăng cường và Đánh giá:
+Áp dụng kỹ thuật Unsharp Masking để làm tăng cường độ sắc nét của ảnh.
+Đo lường tự động và hiển thị trực tiếp lên Web các chỉ số chất lượng ảnh: MSE (Sai số toàn phương trung bình) và PSNR (Tỷ số tín hiệu trên nhiễu đỉnh).

- Thành viên và Phân công nhiệm vụ
Lê Hồ Mỹ Loan: Chịu trách nhiệm thiết kế bộ khung giao diện Web App bằng Streamlit và lập trình các hàm mô phỏng sự suy biến của ảnh (Nhiễu & Nhòe). @lehomyloan

Lê Xuân Thành: Chịu trách nhiệm mảng không gian, lập trình nhóm thuật toán Xử lý Nhiễu bao gồm Lọc Box, Gaussian, và Median. @Thanh851

Phùng Đoàn Lê Hân: Chịu trách nhiệm mảng tần số, lập trình nhóm thuật toán Xử lý Nhòe thông qua biến đổi Fourier bao gồm Lọc Inverse và Lọc Wiener. @hanphungdoanle

Đặng Lê Khánh Ly: Chịu trách nhiệm thuật toán tăng cường ảnh (Unsharp Masking), xây dựng hàm tính toán các chỉ số đánh giá (MSE, PSNR) và là người trực tiếp lắp ráp (integrate) toàn bộ thuật toán của nhóm vào luồng hoạt động chính của Web App. @khanhly297
