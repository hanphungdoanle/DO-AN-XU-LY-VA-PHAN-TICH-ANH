function I_rec = lucy_richardson_filter(I_blur, PSF, NUMIT)
% LUCY_RICHARDSON_FILTER Khôi phục ảnh nhòe bằng thuật toán Richardson-Lucy
% I_blur: Ảnh đầu vào bị nhòe (ảnh xám)
% PSF: Ma trận Kernel gây nhòe
% NUMIT: Số vòng lặp (Mặc định là 20 nếu không truyền vào)

% Kiểm tra nếu người dùng không truyền số vòng lặp thì mặc định là 20
if nargin < 3
    NUMIT = 20; 
end

% Đưa ảnh về chuẩn double để deconvlucy xử lý tốt nhất
I_blur_double = im2double(I_blur);

% Gọi hàm xử lý cốt lõi của MATLAB theo yêu cầu
I_rec_double = deconvlucy(I_blur_double, PSF, NUMIT);

% Đưa ảnh về định dạng hiển thị uint8 (0-255)
I_rec = im2uint8(I_rec_double);
end