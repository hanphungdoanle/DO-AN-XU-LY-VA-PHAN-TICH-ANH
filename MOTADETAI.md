# Ứng dụng các kĩ thuật xử lí ảnh để giải quyết vấn đề nhiễu và nhòe:
Mô tả đề tài:
Đồ án tập trung ứng dụng các kỹ thuật xử lý ảnh để khôi phục ảnh bị suy biến do nhiễu (noise) và nhòe (blur). 
Hệ thống tích hợp 6 thuật toán xử lý khác nhau, cho phép người dùng tải ảnh lên, chọn loại nhiễu/nhòe, áp dụng thuật toán và so sánh kết quả trực quan

Các tính năng dự tính được thực hiện:

Tính năng chính của hệ thống:
- Tương tác trực quan: Cho phép người dùng tải lên một bức ảnh bất kỳ từ máy tính.
- Mô phỏng suy biến: Hỗ trợ tính năng chủ động thêm các loại nhiễu (Nhiễu Gaussian, Nhiễu Salt&Pepper) hoặc tạo hiệu ứng nhòe (Motion blur) vào ảnh gốc để làm dữ liệu thử nghiệm.
- Xử lý và Khôi phục: Cung cấp bộ lọc tích hợp 6 thuật toán khác nhau để người dùng lựa chọn và áp dụng lên ảnh bị suy biến.
- So sánh đa chiều: Hiển thị song song ảnh trước và sau khi xử lý để quan sát bằng mắt thường.

  
Các thuật toán được áp dụng:
- Xử lí nhiễu:
  + Lọc trung vị (Median filter)
  + Lấy trung bình ảnh(Image averaging) 
  + Lowpass filtering/Box&Gausian filtering)
- Xử lí nhòa:
  + Lọc inverse (iFFT)
  + Lọc Wiener Filtering
  + Unsharp Masking (Highpass Sharpening)
# Thành viên nhóm:
1. Phùng Đoàn Lê Hân
2. Đặng Lê Khánh Ly
3. Lê Xuân Thành
4. Lê Hồ Mỹ Loan
# Phân công công việc:
# Tiến độ:
Tuần 1: Tìm hiểu đề tài
