function visualize(number_of_stages, stage_trajectories, legends, plot_name)
    % visualize Plots the trajectory and velocities of the stages.
    
    addpath("gif_generation")
    main_frame = figure(2);
    axis tight manual
    filename = char(plot_name + ".gif");
    
    colors = distinguishable_colors(3);
    colors = [colors(1), colors(1), colors(2), colors(2), colors(3), colors(1), colors(2)];
    linestyles = ["-", "--", "-", "--", "-", "--", "--"];
    
    frame_delay_time = 1/15;
%     gif(filename)
    time_scaling = 15; % 15 seconds in simulation is 1 second in animation
    time_of_next_frame = 0;
    sim_dur_between_frames = time_scaling*frame_delay_time;
    
    subplot(2,1,1)
    hold on
    grid on
    subplot(2,1,2)
    hold on
    grid on
    fontsize_big = 14;
    fontsize_small = 12;
    default_line_width = 1.5;
    
    set(0,'defaulttextinterpreter','latex')
    set(0,'DefaultTextFontname', 'CMU Serif')
    set(0,'DefaultAxesFontName', 'CMU Serif')   
    
    for n = 1:number_of_stages
        t_list = stage_trajectories{n,1};
        u_list = stage_trajectories{n,2};
        total_indexes = size(t_list);
        duration_of_trajectory = t_list(end)-t_list(1);
        index_step = (duration_of_trajectory/time_scaling)/(total_indexes*frame_delay_time);
        subplot(2,1,1)
        plot_1 = plot([0],[0], "linewidth", default_line_width, 'color', colors(n,:));
        subplot(2,1,2)
        plot_2 = plot([0], [0], "linewidth", default_line_width, 'color', colors(n,:));
        for m = 1:index_step:size(t_list)
            current_time = t_list(m);
            t = t_list(1:m);
            x = u_list(1:m,3);
            y = u_list(1:m,4);
            V = u_list(1:m,1);
            subplot(2,1,1)
            plot(x/1000,y/1000, "linewidth", default_line_width, 'color', colors(n,:))
%             set(plot_1, 'XData', x/1000, 'YData', y/1000)
            axis([-10, max(x(end)/1000*1.05,10), 0, y(end)/1000*1.05])
            subplot(2,1,2)
            plot(t, V/1000, "linewidth", default_line_width, 'color', colors(n,:))
            axis([-1, max(t(end)*1.05,10), 0, max(V(end)/1000*1.05,.1)])

            
%             set(plot_2, 'XData', t_list, 'YData', V/1000);
%             if current_time > time_of_next_frame
%                 frame = getframe(2);
%                 im = frame2im(frame);
%                 [imind,cm] = rgb2ind(im,256);
%                 if n == 1 && m == 1
%                     imwrite(imind,cm,filename,'gif','LoopCount',inf,'DelayTime',frame_delay_time); 
%                 else
%                     imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',frame_delay_time);
%                 end
%                 time_of_next_frame = time_of_next_frame + sim_dur_between_frames; 
%             end
            pause(0.1)
        end
    end
    
    subplot(2,1,1)
    xlabel("x / [km]", 'FontSize', fontsize_small)
    ylabel("y / [km]", 'FontSize', fontsize_small)
    subplot(2,1,2)
    xlabel("t / [s]", 'FontSize', fontsize_small)
    ylabel("V / [km/s]", 'FontSize', fontsize_small)
    
    subplot(2,1,1)
    title(plot_name, 'FontSize', fontsize_big)
    legend(legends, 'location', 'southeast', 'fontname', 'CMU Serif', 'FontSize', fontsize_small)

    print(plot_name+".png", "-dpng", "-r300")
end