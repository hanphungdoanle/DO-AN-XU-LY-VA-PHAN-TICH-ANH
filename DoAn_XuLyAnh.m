classdef DoAn_XuLyAnh < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        MoPhongNhoePanel           matlab.ui.container.Panel
        TaoNhoeButton              matlab.ui.control.Button
        ThetaEditField             matlab.ui.control.NumericEditField
        GcthetaEditFieldLabel      matlab.ui.control.Label
        LenEditField               matlab.ui.control.NumericEditField
        dilenEditFieldLabel        matlab.ui.control.Label
        
        MoPhongNhieuPanel          matlab.ui.container.Panel
        SPDropDown                 matlab.ui.control.DropDown
        NhiuSPDropDownLabel        matlab.ui.control.Label
        GaussianDropDown           matlab.ui.control.DropDown
        NhiuGaussianDropDownLabel  matlab.ui.control.Label
        
        TaiDuLieuPanel             matlab.ui.container.Panel
        TaiAnhButton               matlab.ui.control.Button
        
        % --- CÁC COMPONENT THÊM MỚI CHO NHIỆM VỤ CỦA LY ---
        XuLyPanel                  matlab.ui.container.Panel
        FilterDropDownLabel        matlab.ui.control.Label
        FilterDropDown             matlab.ui.control.DropDown
        KhoiPhucButton             matlab.ui.control.Button
        MSELabel                   matlab.ui.control.Label
        PSNRLabel                  matlab.ui.control.Label
        % ---------------------------------------------------
        
        UIAxes3_KhoiPhuc           matlab.ui.control.UIAxes
        UIAxes_Loi                 matlab.ui.control.UIAxes
        UIAxes_Goc                 matlab.ui.control.UIAxes
    end

    properties (Access = private)
        I_goc % Chứa ảnh gốc ban đầu
        I_loi % Chứa ảnh sau khi bị nhiễu/nhòe
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: TaiAnhButton
        function TaiAnhButtonPushed(app, event)
            % Mở hộp thoại chọn file ảnh từ máy tính
            [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files'});
            if isequal(file, 0)
                return;
            end
            img_path = fullfile(path, file);
            
            app.I_goc = imread(img_path);
            if size(app.I_goc, 3) == 3
                app.I_goc = rgb2gray(app.I_goc);
            end
            imshow(app.I_goc, 'Parent', app.UIAxes_Goc);
            title(app.UIAxes_Goc, 'Ảnh Gốc');
        end

        % Value changed function: GaussianDropDown
        function GaussianDropDownValueChanged(app, event)
            if isempty(app.I_goc), return; end
            variance_str = app.GaussianDropDown.Value; 
            variance = str2double(variance_str);       
            
            app.I_loi = imnoise(app.I_goc, 'gaussian', 0, variance);
            imshow(app.I_loi, 'Parent', app.UIAxes_Loi);
            title(app.UIAxes_Loi, sprintf('Ảnh Lỗi (Gaussian: %s)', variance_str));
        end

        % Value changed function: SPDropDown
        function SPDropDownValueChanged(app, event)
            if isempty(app.I_goc), return; end
            density_str = app.SPDropDown.Value;
            density = str2double(density_str);
            
            app.I_loi = imnoise(app.I_goc, 'salt & pepper', density);
            imshow(app.I_loi, 'Parent', app.UIAxes_Loi);
            title(app.UIAxes_Loi, sprintf('Ảnh Lỗi (S&P: %s)', density_str));
        end

        % Button pushed function: TaoNhoeButton
        function TaoNhoeButtonPushed(app, event)
            if isempty(app.I_goc), return; end
            len = app.LenEditField.Value;
            theta = app.ThetaEditField.Value;
            
            % Tránh lỗi len = 0 của fspecial
            if len <= 0, len = 1; end 
            
            kernel = fspecial('motion', len, theta);
            app.I_loi = imfilter(app.I_goc, kernel, 'replicate');
            imshow(app.I_loi, 'Parent', app.UIAxes_Loi);
            title(app.UIAxes_Loi, 'Ảnh Lỗi (Motion Blur)');
        end
        
        % =========================================================================
        % CODE CỦA LY: TÍCH HỢP XỬ LÝ VÀ ĐÁNH GIÁ (KhoiPhucButtonPushed)
        % =========================================================================
        function KhoiPhucButtonPushed(app, event)
            if isempty(app.I_loi)
                uialert(app.UIFigure, 'Vui lòng nạp ảnh và tạo nhiễu/nhòe trước!', 'Thông báo');
                return;
            end
            
            method = app.FilterDropDown.Value;
            I_in = app.I_loi;
            
            % Khởi tạo biến chứa kết quả
            I_res = I_in; 
            
            try
                switch method
                    % --- TÍCH HỢP CODE CỦA THÀNH (XỬ LÝ NHIỄU) ---
                    case 'Lọc Trung Bình (Mean)'
                        h = fspecial('average', [3 3]);
                        I_res = imfilter(I_in, h, 'replicate');
                        
                    case 'Lọc Trung Vị (Median)'
                        if size(I_in, 3) == 3, I_in = rgb2gray(I_in); end
                        I_res = medfilt2(I_in, [3 3]);
                        
                    case 'Lọc Gaussian'
                        h = fspecial('gaussian', [3 3], 1.5);
                        I_res = imfilter(I_in, h, 'replicate');
                        
                    % --- TÍCH HỢP CODE CỦA HÂN (XỬ LÝ NHÒE) ---
                    case 'Lọc Inverse (iFFT)'
                        len = app.LenEditField.Value; if len <= 0, len = 15; end
                        theta = app.ThetaEditField.Value;
                        PSF = fspecial('motion', len, theta);
                        
                        I_blur_double = im2double(I_in);
                        G = fft2(I_blur_double);
                        H = fft2(PSF, size(I_blur_double,1), size(I_blur_double,2));
                        F_hat = G ./ (H + 0.01);
                        I_res = im2uint8(real(ifft2(F_hat)));
                        
                    case 'Lọc Richardson-Lucy'
                        len = app.LenEditField.Value; if len <= 0, len = 15; end
                        theta = app.ThetaEditField.Value;
                        PSF = fspecial('motion', len, theta);
                        
                        I_blur_double = im2double(I_in);
                        I_res_double = deconvlucy(I_blur_double, PSF, 20);
                        I_res = im2uint8(I_res_double);
                        
                    % --- CODE CỦA LY (TĂNG CƯỜNG ẢNH) ---
                    case 'Unsharp Masking (Ly)'
                        I_res = imsharpen(I_in, 'Radius', 2, 'Amount', 1);
                end
                
                % HIỂN THỊ ẢNH KHÔI PHỤC
                imshow(I_res, 'Parent', app.UIAxes3_KhoiPhuc);
                title(app.UIAxes3_KhoiPhuc, ['Khôi Phục: ', method]);
                
                % TÍNH TOÁN CHỈ SỐ ĐÁNH GIÁ MSE & PSNR (Nhiệm vụ của Ly)
                % Đảm bảo kích thước bằng nhau để tính toán
                I_goc_resized = imresize(app.I_goc, size(I_res));
                
                mse_value = immse(I_res, I_goc_resized);
                psnr_value = psnr(I_res, I_goc_resized);
                
                % Hiển thị lên giao diện
                app.MSELabel.Text = sprintf('MSE: %.4f', mse_value);
                app.PSNRLabel.Text = sprintf('PSNR: %.2f dB', psnr_value);
                
            catch ME
                uialert(app.UIFigure, ['Lỗi trong quá trình xử lý: ' ME.message], 'Lỗi Thuật Toán');
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            % Create UIFigure
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 680 500]; % Tăng chiều rộng để chứa Panel mới
            app.UIFigure.Name = 'MATLAB App - Đồ Án Xử Lý Ảnh';

            % Create UIAxes_Goc
            app.UIAxes_Goc = uiaxes(app.UIFigure);
            title(app.UIAxes_Goc, 'Ảnh Gốc')
            app.UIAxes_Goc.XTick = [];
            app.UIAxes_Goc.YTick = [];
            app.UIAxes_Goc.Position = [420 310 240 170];

            % Create UIAxes_Loi
            app.UIAxes_Loi = uiaxes(app.UIFigure);
            title(app.UIAxes_Loi, 'Ảnh Lỗi')
            app.UIAxes_Loi.XTick = [];
            app.UIAxes_Loi.YTick = [];
            app.UIAxes_Loi.Position = [230 160 200 160];

            % Create UIAxes3_KhoiPhuc
            app.UIAxes3_KhoiPhuc = uiaxes(app.UIFigure);
            title(app.UIAxes3_KhoiPhuc, 'Ảnh Khôi Phục')
            app.UIAxes3_KhoiPhuc.XTick = [];
            app.UIAxes3_KhoiPhuc.YTick = [];
            app.UIAxes3_KhoiPhuc.Position = [440 10 230 180];

            % Create TaiDuLieuPanel
            app.TaiDuLieuPanel = uipanel(app.UIFigure);
            app.TaiDuLieuPanel.Title = 'Tải Dữ Liệu';
            app.TaiDuLieuPanel.Position = [10 400 200 70];

            % Create TaiAnhButton
            app.TaiAnhButton = uibutton(app.TaiDuLieuPanel, 'push');
            app.TaiAnhButton.ButtonPushedFcn = createCallbackFcn(app, @TaiAnhButtonPushed, true);
            app.TaiAnhButton.Position = [50 15 100 25];
            app.TaiAnhButton.Text = 'Tải Ảnh';

            % Create MoPhongNhieuPanel
            app.MoPhongNhieuPanel = uipanel(app.UIFigure);
            app.MoPhongNhieuPanel.Title = 'Mô Phỏng Nhiễu';
            app.MoPhongNhieuPanel.Position = [10 280 200 110];

            % Create NhiuGaussianDropDownLabel
            app.NhiuGaussianDropDownLabel = uilabel(app.MoPhongNhieuPanel);
            app.NhiuGaussianDropDownLabel.HorizontalAlignment = 'right';
            app.NhiuGaussianDropDownLabel.Position = [10 50 90 22];
            app.NhiuGaussianDropDownLabel.Text = 'Nhiễu Gaussian';

            % Create GaussianDropDown
            app.GaussianDropDown = uidropdown(app.MoPhongNhieuPanel);
            app.GaussianDropDown.Items = {'0.01', '0.05'};
            app.GaussianDropDown.ValueChangedFcn = createCallbackFcn(app, @GaussianDropDownValueChanged, true);
            app.GaussianDropDown.Position = [110 50 80 22];
            app.GaussianDropDown.Value = '0.01';

            % Create NhiuSPDropDownLabel
            app.NhiuSPDropDownLabel = uilabel(app.MoPhongNhieuPanel);
            app.NhiuSPDropDownLabel.HorizontalAlignment = 'right';
            app.NhiuSPDropDownLabel.Position = [10 15 90 22];
            app.NhiuSPDropDownLabel.Text = 'Nhiễu S&P';

            % Create SPDropDown
            app.SPDropDown = uidropdown(app.MoPhongNhieuPanel);
            app.SPDropDown.Items = {'0.05', '0.1'};
            app.SPDropDown.ValueChangedFcn = createCallbackFcn(app, @SPDropDownValueChanged, true);
            app.SPDropDown.Position = [110 15 80 22];
            app.SPDropDown.Value = '0.05';

            % Create MoPhongNhoePanel
            app.MoPhongNhoePanel = uipanel(app.UIFigure);
            app.MoPhongNhoePanel.Title = 'Mô Phỏng Nhòe';
            app.MoPhongNhoePanel.Position = [10 130 200 140];

            % Create dilenEditFieldLabel
            app.dilenEditFieldLabel = uilabel(app.MoPhongNhoePanel);
            app.dilenEditFieldLabel.HorizontalAlignment = 'right';
            app.dilenEditFieldLabel.Position = [10 85 70 22];
            app.dilenEditFieldLabel.Text = 'Độ dài (len)';

            % Create LenEditField
            app.LenEditField = uieditfield(app.MoPhongNhoePanel, 'numeric');
            app.LenEditField.Position = [90 85 100 22];

            % Create GcthetaEditFieldLabel
            app.GcthetaEditFieldLabel = uilabel(app.MoPhongNhoePanel);
            app.GcthetaEditFieldLabel.HorizontalAlignment = 'right';
            app.GcthetaEditFieldLabel.Position = [10 50 70 22];
            app.GcthetaEditFieldLabel.Text = 'Góc (theta)';

            % Create ThetaEditField
            app.ThetaEditField = uieditfield(app.MoPhongNhoePanel, 'numeric');
            app.ThetaEditField.Position = [90 50 100 22];

            % Create TaoNhoeButton
            app.TaoNhoeButton = uibutton(app.MoPhongNhoePanel, 'push');
            app.TaoNhoeButton.ButtonPushedFcn = createCallbackFcn(app, @TaoNhoeButtonPushed, true);
            app.TaoNhoeButton.Position = [50 15 100 25];
            app.TaoNhoeButton.Text = 'Tạo Nhòe';
            
            % ==========================================================
            % THÊM MỚI PANEL XỬ LÝ (DÀNH CHO NHIỆM VỤ CỦA LY)
            % ==========================================================
            app.XuLyPanel = uipanel(app.UIFigure);
            app.XuLyPanel.Title = 'Khôi Phục & Đánh Giá';
            app.XuLyPanel.Position = [220 10 200 140];
            
            % Dropdown Lựa chọn Bộ lọc
            app.FilterDropDownLabel = uilabel(app.XuLyPanel);
            app.FilterDropDownLabel.Position = [10 90 180 22];
            app.FilterDropDownLabel.Text = 'Chọn thuật toán xử lý:';
            
            app.FilterDropDown = uidropdown(app.XuLyPanel);
            app.FilterDropDown.Items = {'Lọc Trung Bình (Mean)', 'Lọc Trung Vị (Median)', 'Lọc Gaussian', 'Lọc Inverse (iFFT)', 'Lọc Richardson-Lucy', 'Unsharp Masking'};
            app.FilterDropDown.Position = [10 65 180 22];
            
            % Nút chạy khôi phục
            app.KhoiPhucButton = uibutton(app.XuLyPanel, 'push');
            app.KhoiPhucButton.ButtonPushedFcn = createCallbackFcn(app, @KhoiPhucButtonPushed, true);
            app.KhoiPhucButton.Position = [50 35 100 25];
            app.KhoiPhucButton.Text = 'Thực Hiện';
            app.KhoiPhucButton.FontWeight = 'bold';
            
            % Labels Đánh giá MSE / PSNR
            app.MSELabel = uilabel(app.XuLyPanel);
            app.MSELabel.Position = [10 10 90 22];
            app.MSELabel.Text = 'MSE: ---';
            app.MSELabel.FontColor = [0.85 0.325 0.098];
            
            app.PSNRLabel = uilabel(app.XuLyPanel);
            app.PSNRLabel.Position = [100 10 90 22];
            app.PSNRLabel.Text = 'PSNR: ---';
            app.PSNRLabel.FontColor = [0 0.447 0.741];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = DoAn_XuLyAnh
            % Create UIFigure and components
            createComponents(app)
            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end