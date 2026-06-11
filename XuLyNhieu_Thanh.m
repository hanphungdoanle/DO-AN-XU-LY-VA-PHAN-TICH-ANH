% =========================================================================
% ĐỒ ÁN XỬ LÝ ẢNH - TASK 2: XỬ LÝ NHIỄU (SPATIAL DOMAIN FILTERING)
% Người thực hiện: Lê Xuân Thành
% =========================================================================

function XuLyNhieu_Thanh()
% =====================================================================
% PHẦN 1: HÀM MAIN ĐỂ CHẠY TEST ĐỘC LẬP (LẤY ẢNH ĐƯA VÀO BÁO CÁO)
% =====================================================================
clc; clear; close all;

% 1. Đọc ảnh mẫu (sử dụng ảnh cameraman mặc định của MATLAB)
img = imread('cameraman.tif');
if size(img, 3) == 3
    img = rgb2gray(img); % Đảm bảo là ảnh xám
end

% 2. Mượn tạm code tạo nhiễu để có dữ liệu test thuật toán của mình
% Thêm nhiễu Gaussian (phương sai 0.02)
img_gaussian = imnoise(img, 'gaussian', 0, 0.02);
% Thêm nhiễu Salt & Pepper (mật độ 0.05)
img_sp = imnoise(img, 'salt & pepper', 0.05);

% 3. GỌI CÁC HÀM XỬ LÝ NHIỄU ĐÃ VIẾT Ở BÊN DƯỚI
% Test Lọc Mean & Gaussian trên ảnh nhiễu Gaussian
res_mean = apply_mean_filter(img_gaussian, 3);          % Kernel 3x3
res_gaussian = apply_gaussian_filter(img_gaussian, 3, 1.5); % Kernel 3x3, sigma 1.5

% Test Lọc Median trên ảnh nhiễu Salt & Pepper
res_median = apply_median_filter(img_sp, 3);            % Kernel 3x3

% 4. HIỂN THỊ KẾT QUẢ TRỰC QUAN ĐỂ CHỤP MÀN HÌNH
figure('Name', 'Ket Qua Xu Ly Nhieu - Le Xuan Thanh', 'Position', [100, 100, 1200, 600]);

% Hàng 1: Xử lý nhiễu Gaussian
subplot(2, 3, 1); imshow(img_gaussian); title('1. Ảnh bị nhiễu Gaussian');
subplot(2, 3, 2); imshow(res_mean); title('2. Lọc Trung Bình (Mean)');
subplot(2, 3, 3); imshow(res_gaussian); title('3. Lọc Gaussian');

% Hàng 2: Xử lý nhiễu Salt & Pepper
subplot(2, 3, 4); imshow(img_sp); title('4. Ảnh bị nhiễu Salt & Pepper');
subplot(2, 3, 5); imshow(res_median); title('5. Lọc Trung Vị (Median)');

disp('Đã chạy xong các thuật toán lọc nhiễu của Thành!');
end

% =========================================================================
% PHẦN 2: CÁC HÀM THUẬT TOÁN (BÀN GIAO CHO LY GẮN VÀO GUI)
% =========================================================================

% -------------------------------------------------------------------------
% HÀM 2.1: LỌC TRUNG BÌNH (MEAN / BOX FILTERING)
% -------------------------------------------------------------------------
function out_img = apply_mean_filter(in_img, kernel_size)
% Tạo mặt nạ (kernel) trung bình bằng fspecial
h = fspecial('average', [kernel_size kernel_size]);
% Áp dụng phép chập (convolution), dùng 'replicate' để mượt phần viền ảnh
out_img = imfilter(in_img, h, 'replicate');
end

% -------------------------------------------------------------------------
% HÀM 2.2: LỌC GAUSSIAN
% -------------------------------------------------------------------------
function out_img = apply_gaussian_filter(in_img, kernel_size, sigma)
% Tạo mặt nạ Gaussian dựa trên kích thước và độ lệch chuẩn sigma
h = fspecial('gaussian', [kernel_size kernel_size], sigma);
% Áp dụng phép chập
out_img = imfilter(in_img, h, 'replicate');
end

% -------------------------------------------------------------------------
% HÀM 2.3: LỌC TRUNG VỊ (MEDIAN FILTER)
% -------------------------------------------------------------------------
function out_img = apply_median_filter(in_img, kernel_size)
% Cần chuyển sang ảnh xám trước khi dùng medfilt2 nếu đầu vào vô tình là ảnh màu
if size(in_img, 3) == 3
    in_img = rgb2gray(in_img);
end
% Áp dụng hàm lọc trung vị (phi tuyến) có sẵn của MATLAB
out_img = medfilt2(in_img, [kernel_size kernel_size]);
end