function visualize_animation(number_of_stages, trajectories, legends, plot_name)
    % visualize Plots the trajectory and velocities of the stages.
    
    %% Entire trajectory

    figure(1)
    
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
    
    colors = [51, 153, 255; 51, 51, 255; % Stage 1
        255, 102, 51; 255, 204, 51; % Stage 2;
        204, 51, 255; % Payload
        0, 0, 0]/256; % Target
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
    l = legend(legends, 'location', 'northeast', 'fontname', 'CMU Serif', 'FontSize', fontsize_small);

    print(plot_name+".png", "-dpng", "-r300")
    
    %% First stage trajectory 
    
    figure(2)
    
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
    
    colors = [51, 153, 255; 51, 51, 255; % Stage 1
        255, 102, 51; 255, 204, 51; % Stage 2;
        204, 51, 255; % Payload
        0, 0, 0]/256; % Target
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
    plot_name_first_stage = plot_name + " - 1st stage";
    title(plot_name_first_stage, 'FontSize', fontsize_big)
    l = legend(legends, 'location', 'south', 'fontname', 'CMU Serif', 'FontSize', fontsize_small);

    t_list = trajectories{2,1}; % Get first stage states
    u_list = trajectories{2,2};
    subplot(2,1,1)
    axis([0 max(u_list(:,3))/1000 0 max(u_list(:,4))/1000])
    subplot(2,1,2)
    axis([0 max(t_list) 0 max(u_list(:,1))/1000])

    print(plot_name_first_stage+".png", "-dpng", "-r300")
    
    %% Delta V plot
    
    
    
end