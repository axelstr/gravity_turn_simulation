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
    linewidths = [1.5,1.5,1.5,1.5,1.5,.5]*default_line_width;
    
    
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

    print(strrep(plot_name," ","_")+".png", "-dpng", "-r300")
    
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

    print(strrep(plot_name_first_stage," ","_")+".png", "-dpng", "-r300")
    
    %% Delta V plot
    
    figure(3)
    hold on
    grid on
    deltaV_title = plot_name + ' - accumulative $\Delta V$';
    title(deltaV_title, 'fontsize', fontsize_big)
    plot([0, 0], [0,0], 'color', 'k', 'linewidth', 1, 'linestyle', "-")
    plot([0, 0], [0,0], 'color', 'k', 'linewidth', 1, 'linestyle', "--")
    plot([0, 0], [0,0], 'color', 'k', 'linewidth', 1, 'linestyle', ":")
    xlabel("t / [s]", 'FontSize', fontsize_small)
    ylabel("V / [km/s]", 'FontSize', fontsize_small)
    
    delta_v_legends = ["$\Delta V_{\textrm{thrust}}$", "$\Delta V_{\textrm{drag}}$", "$\Delta V_{\textrm{gravity}}$", legends];
 
    for n = 1:number_of_stages-1
        t_list = trajectories{n,1};
        u_list = trajectories{n,2};
        deltaV_thrust = u_list(:,6);
        deltaV_drag = u_list(:,7);
        deltaV_grav = u_list(:,8);
        plot(t_list, deltaV_thrust/1000, "linewidth", 1.5, "color", colors(n,:), "linestyle", "-");
    end
    
    legend(delta_v_legends, 'location', 'eastoutside', 'interpreter', 'latex')
    
    for n = 1:number_of_stages-1
        t_list = trajectories{n,1};
        u_list = trajectories{n,2};
        deltaV_thrust = u_list(:,6);
        deltaV_drag = u_list(:,7);
        deltaV_grav = u_list(:,8);
        plot(t_list, deltaV_drag/1000, "linewidth", 1.5, "color", colors(n,:), "linestyle", "--", 'HandleVisibility','off');
        plot(t_list, deltaV_grav/1000, "linewidth", 2, "color", colors(n,:), "linestyle", ":", 'HandleVisibility','off');
    end
    
    deltaV_plot_name = plot_name + " - delta V";
    print(strrep(deltaV_plot_name," ","_")+".png", "-dpng", "-r300")
    
    
end