function visualize_animation(number_of_stages, trajectories, legends, plot_name)
    % visualize Plots the trajectory and velocities of the stages.
    
    subplot(2,1,1)
    hold on
    grid on
    subplot(2,1,2)
    hold on
    grid on
    fontsize_big = 14;
    fontsize_small = 10;

    
    default_line_width = 1;
    set(0,'defaulttextinterpreter','latex')
    set(0,'DefaultTextFontname', 'CMU Serif')
    set(0,'DefaultAxesFontName', 'CMU Serif')   
    
%     colors = distinguishable_colors(3);
%     colors = [colors(1,:); colors(1,:); colors(2,:); colors(2,:); colors(3,:); colors(1,:); colors(2,:)];
    colors = [51, 153, 255; 51, 51, 255; % Stage 1
        255, 102, 51; 255, 204, 51; % Stage 2;
        204, 51, 255; % Payload
        0, 0, 0]/256; % Target
%     linestyles = ["-", "-.", "-", "--", "-", ":", ":"];%     
    linestyles = ["-", "-", "-", "-", "-", "--"];
    linewidths = [1,1,1,1,1,.5]*default_line_width;
    
    
    for n = 1:number_of_stages
        t_list = trajectories{n,1};
        u_list = trajectories{n,2};
        x = u_list(:,3);
        y = u_list(:,4);
        V = u_list(:,1);
        subplot(2,1,1)
        plot(x/1000,y/1000, "linewidth", linewidths(n), "color", colors(n,:), "linestyle", linestyles(n))
        subplot(2,1,2)
        plot(t_list, V/1000, "linewidth", linewidths(n), "color", colors(n,:), "linestyle", linestyles(n));
    end
    
    subplot(2,1,1)
    xlabel("x / [km]", 'FontSize', fontsize_small)
    ylabel("y / [km]", 'FontSize', fontsize_small)
    subplot(2,1,2)
    xlabel("t / [s]", 'FontSize', fontsize_small)
    ylabel("V / [km/s]", 'FontSize', fontsize_small)
    
    subplot(2,1,1)
    title(plot_name, 'FontSize', fontsize_big)
%     % --- Legend fixes
%     % set unit for figure size to inches
%     set(gcf, 'unit', 'inches');
%     % get the original size of figure before the legends are added
%     figure_size =  get(gcf, 'position');
%     % add legends and get its handle
%     h_legend = legend('legend1', legends)
%     set(h_legend, 'location', 'northeastoutside')
%     % set unit for legend size to inches
%     set(h_legend, 'unit', 'inches')
%     % get legend size
%     legend_size = get(h_legend, 'position');
%     % new figure width
%     figure_size(3) = figure_size(3) + legend_size(3);
%     % set new figure size
%     set(gcf, 'position', figure_size)
    l = legend(legends, 'location', 'south', 'fontname', 'CMU Serif', 'FontSize', fontsize_small);

    print(plot_name+".png", "-dpng", "-r300")
    
    if input("Show 1st stage trajectory? (y/n)", 's') == "y"
        % --- Plot of first stage
        plot_name_first_stage = plot_name + " - 1st stage";
        title(plot_name_first_stage, 'FontSize', fontsize_big)

        t_list = trajectories{2,1}; % Get first stage states
        u_list = trajectories{2,2};
        subplot(2,1,1)
        axis([0 max(u_list(:,3))/1000 0 max(u_list(:,4))/1000])
        subplot(2,1,2)
        axis([0 max(t_list) 0 max(u_list(:,1))/1000])

        print(plot_name_first_stage+".png", "-dpng", "-r300")
    end
    
end