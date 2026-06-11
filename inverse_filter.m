function I_rec = inverse_filter(I_blur, PSF, epsilon)
% INVERSE_FILTER Khôi phục ảnh nhòe bằng bộ lọc ngược (iFFT)
% I_blur: Ảnh đầu vào bị nhòe (ảnh xám)
% PSF: Ma trận Kernel gây nhòe
% epsilon: Hằng số nhỏ thêm vào mẫu số để tránh lỗi chia cho 0

% Thiết lập giá trị mặc định cho epsilon nếu không truyền vào
if nargin < 3
    epsilon = 0.01; 
end

% Bước 1: Đưa ảnh về chuẩn double để tính toán chính xác
I_blur_double = im2double(I_blur);
[M, N] = size(I_blur_double);

% Bước 2: Chuyển ảnh nhòe sang miền tần số bằng fft2
G = fft2(I_blur_double);

% Bước 3: Chuyển Kernel (PSF) sang miền tần số
% (Cấp phát kích thước M, N để phổ của PSF bằng kích thước phổ của ảnh)
H = fft2(PSF, M, N);

% Bước 4: Thực hiện lọc ngược (Lấy G chia H)
% Cộng thêm epsilon vào H để tránh chia cho 0 tại các điểm tần số bằng 0
F_hat = G ./ (H + epsilon);

% Bước 5: Đưa ảnh từ miền tần số về lại không gian bằng ifft2
% Lấy phần thực (real) vì trong quá trình biến đổi có thể sinh ra số phức do sai số
I_rec_double = real(ifft2(F_hat));

% Bước 6: Chuẩn hóa và đưa ảnh về định dạng hiển thị uint8 (0-255)
I_rec = im2uint8(I_rec_double);
end