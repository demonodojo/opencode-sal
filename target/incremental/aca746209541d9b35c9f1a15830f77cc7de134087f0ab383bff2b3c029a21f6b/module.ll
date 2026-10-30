target triple = "x86_64-unknown-none-elf"

%SalBytes = type { ptr, i64 }
@sal_bytes_oob = private unnamed_addr constant [20 x i8] c"bytes: out of bounds"

declare i64 @sal_print_i64(i64)
declare void @sal_panic(ptr)
declare void @sal_bytes_check(i64, i64, i64)
declare i64 @sal_os_syscall(i64, i64, i64, i64, i64, i64, i64)
declare void @sal_matmul_f32(ptr, ptr, ptr, i64, i64, i64)
declare void @sal_matmul_f16(ptr, ptr, ptr, i64, i64, i64)
declare void @sal_matmul_bf16(ptr, ptr, ptr, i64, i64, i64)
declare void @sal_qmatmul_f32(ptr, ptr, ptr, ptr, i64, i64, i64, i64)
declare void @sal_attention_f32(ptr, ptr, ptr, ptr, i64, i64, i64, i64, i64)
declare void @sal_tensor_write_row_f32(ptr, i64, ptr, i64)
declare void @sal_tensor_write_rows_f32(ptr, i64, ptr, i64, i64)
declare void @sal_softmax_f32(ptr, i64)
declare void @sal_softmax_axis_f32(ptr, i64, i64)
declare void @sal_silu_f32(ptr, ptr, i64)
declare void @sal_rope_f32(ptr, i64, i64, i64)
declare void @sal_rms_norm_f32(ptr, ptr, ptr, i64, double)
declare i64 @sal_argmax_axis_f32(ptr, i64)
declare void @sal_region_begin(i64, i64)
declare void @sal_region_end(i64)
declare void @sal_tensor_bin_f32(i32, ptr, ptr, ptr, i64, i32, double)
declare void @sal_tensor_cmp_f32(i32, ptr, ptr, ptr, i64, i32, double)
declare void @sal_tensor_neg_f32(ptr, ptr, i64)
declare void @sal_tensor_not_i8(ptr, ptr, i64)
declare i64 @sal_mask_select_count(ptr, i64)
declare void @sal_tensor_select_f32(ptr, ptr, ptr, i64)
declare void @sal_tensor_select_i8(ptr, ptr, ptr, i64)
declare ptr @sal_list_select(ptr, ptr, i64)
declare ptr @sal_load_f32(ptr, ptr)
declare ptr @sal_place_malloc(i64, i32)
declare void @sal_place_free(ptr)
declare ptr @sal_place_copy(ptr, i64, i32)
declare void @sal_on_enter(i32)
declare i64 @sal_place_launches(i64)
declare ptr @malloc(i64)
declare void @free(ptr)
declare void @sal_runtime_init(i64, ptr)
declare i64 @sal_argc()
declare ptr @sal_argv(i64)
declare ptr @sal_read_file(ptr)
declare i64 @sal_path_readable(ptr)
declare i64 @sal_write_file(ptr, ptr)
declare i64 @sal_write_png(ptr, i64, i64, ptr)
declare ptr @sal_image_new(i64, i64)
declare i64 @sal_print_str(ptr)
declare i64 @sal_eprint_str(ptr)
declare ptr @sal_getenv(ptr)
declare i64 @sal_mkdir_p(ptr)
declare i64 @sal_str_eq(ptr, ptr)
declare i64 @sal_str_contains(ptr, ptr)
declare i64 @sal_str_len(ptr)
declare i64 @sal_str_bytes(ptr)
declare ptr @sal_str_concat(ptr, ptr)
declare ptr @sal_str_append(ptr, ptr)
declare ptr @sal_strdup(ptr)
declare ptr @sal_select_str(i64, ptr, ptr)
declare void @sal_free(ptr)
declare i64 @sal_copy_file(ptr, ptr)
declare i64 @sal_copy_self(ptr)
declare i64 @sal_not(i64)
declare i64 @sal_gated_print_str(i64, ptr)
declare i64 @sal_gated_copy_self(i64, ptr)
declare i64 @sal_str_char(ptr, i64)
declare i64 @sal_str_skip(ptr, i64, i64, i64)
declare i64 @sal_str_hash(ptr, i64)
declare ptr @sal_map_new()
declare i64 @sal_map_get(ptr, ptr)
declare i64 @sal_map_put(ptr, ptr, i64)
declare ptr @sal_ir_text(ptr)
declare ptr @sal_lex_src(ptr)
declare ptr @sal_str_slice(ptr, i64, i64)
declare ptr @sal_int_to_str(i64)
declare ptr @sal_char_to_str(i64)
declare ptr @sal_str_from_int(i64)
declare i64 @sal_str_as_int(ptr)
declare i64 @sal_str_to_f64_bits(ptr)
declare ptr @sal_f64_bits_to_str(i64)
declare i64 @sal_now_ns()
declare ptr @sal_vec_new()
declare i64 @sal_vec_push(ptr, i64)
declare i64 @sal_vec_get(ptr, i64)
declare i64 @sal_vec_set(ptr, i64, i64)
declare i64 @sal_vec_len(ptr)
declare void @sal_vec_free(ptr)
declare ptr @sal_bytes_new(i64)
declare i64 @sal_bytes_len(ptr)
declare i64 @sal_bytes_fill(ptr, i64, i64, i64)
declare i64 @sal_bytes_fill_u32(ptr, i64, i64, i64)
declare i64 @sal_bytes_copy(ptr, i64, ptr, i64, i64)
declare i64 @sal_str_bytes_copy(ptr, i64, ptr)
declare ptr @sal_bytes_to_str(ptr)
declare ptr @sal_bytes_view(ptr, i64, i64)
declare ptr @sal_bytes_view_mem(i64, i64)
declare i64 @sal_bytes_ptr(ptr)
declare ptr @sal_list_new()
declare ptr @sal_list_new_typed(i64)
declare ptr @sal_list_push(ptr, i64)
declare i64 @sal_list_len(ptr)
declare i64 @sal_list_get(ptr, i64)
declare i64 @sal_clang(ptr, ptr)
declare ptr @sal_realpath(ptr)
declare i64 @sal_clang_obj(ptr, ptr)
declare i64 @sal_link_objs(ptr, ptr)
declare ptr @sal_tmp_path(ptr)
declare ptr @sal_exec_capture(ptr, ptr)
declare i64 @sal_exec_compile(ptr, ptr, ptr)
declare i64 @sal_gated_exec_compile(i64, ptr, ptr, ptr)
declare void @sal_instrument_init()
declare void @sal_instrument_shutdown()
declare ptr @sal_instrument_malloc(i64, i32, ptr)
declare void @sal_instrument_alloc(ptr, i64, i32, ptr)
declare void @sal_instrument_free(ptr)
declare void @sal_instrument_check_f32(ptr, i64, ptr)
declare void @sal_instrument_check_ptr(ptr, i64, i32, ptr)
declare void @sal_instrument_check_index(i64, i64, ptr)
declare ptr @sal_dict_new(i64, i64)
declare ptr @sal_dict_put(ptr, ptr, i64)
declare i64 @sal_dict_get(ptr, ptr)

declare i64 @nr_getdents()
declare i64 @spawn_string_buf(i64 %arg0)
declare i64 @spawnio_off_stdin()
declare i64 @spawnio_off_argv_count()
declare i64 @json_esc(i64 %arg0)
declare i64 @u32_b2(i64 %arg0)
declare i64 @o_RDONLY()
declare i64 @spawnio_off_stderr()
declare i64 @dirent_off_name()
declare i64 @stat_path_ptr(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3)
declare i64 @write_fd(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @nr_getenv()
declare i64 @path_to_buf(i64 %arg0)
declare i64 @unlink_path_ptr(i64 %arg0, i64 %arg1)
declare i64 @spawnio_size()
declare i64 @nr_write()
declare i64 @nr_sleep_ms()
declare i64 @json_emit_done()
declare i64 @kill_pid(i64 %arg0, i64 %arg1)
declare i64 @tcp_listen(i64 %arg0)
declare i64 @nr_open()
declare i64 @read_fd(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @nr_uptime_ms()
declare i64 @dirent_off_file_type()
declare i64 @mod_pos(i64 %arg0, i64 %arg1)
declare i64 @config_base_url()
declare i64 @write_file_path(i64 %arg0, i64 %arg1)
declare i64 @spawnio_off_log_fd()
declare i64 @open_read_path_ptr(i64 %arg0, i64 %arg1)
declare i64 @nr_dns_resolve()
declare i64 @sse_has_data(i64 %arg0)
declare i64 @spawnio_off_argv_ptr()
declare i64 @nr_wait()
declare i64 @agents_md()
declare i64 @tcp_accept(i64 %arg0, i64 %arg1)
declare i64 @spawnio_off_path_ptr()
declare i64 @u8(i64 %arg0)
declare i64 @nr_mkdir()
declare i64 @nr_tcp_accept()
declare i64 @json_emit_line(i64 %arg0, i64 %arg1)
declare i64 @nr_rename()
declare i64 @tcp_connect_loopback(i64 %arg0, i64 %arg1)
declare i64 @session_path(i64 %arg0)
declare i64 @dns_resolve_ptr(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @read_timeout_fd(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3)
declare i64 @session_save(i64 %arg0, i64 %arg1)
declare i64 @chat_body(i64 %arg0, i64 %arg1)
declare i64 @nr_close()
declare i64 @write_str_fd(i64 %arg0, i64 %arg1)
declare i64 @nr_read()
declare i64 @wait_pid(i64 %arg0)
declare i64 @o_WRONLY()
declare i64 @run_once(i64 %arg0, i64 %arg1)
declare i64 @nr_unlink()
declare i64 @dirent_size()
declare i64 @getdents_fd(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @session_load(i64 %arg0)
declare i64 @nr_kill()
declare i64 @open_flags(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @dirent_off_ino()
declare i64 @close_fd(i64 %arg0)
declare i64 @spawnio_off_stdout()
declare i64 @http_post(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @nr_tcp_connect()
declare i64 @http_read_body(i64 %arg0, i64 %arg1)
declare i64 @config_model()
declare i64 @mkdir_path_ptr(i64 %arg0, i64 %arg1)
declare i64 @ft_dir()
declare i64 @open_read(i64 %arg0)
declare i64 @o_CREAT()
declare i64 @sockaddr_loopback(i64 %arg0)
declare i64 @spawn_io_full(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3, i64 %arg4)
declare i64 @nr_spawn_io()
declare i64 @nr_tcp_listen()
declare i64 @nr_stat()
declare i64 @spawn_argv_slot_ptr(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3)
declare i64 @ft_file()
declare i64 @sse_stub_content()
declare i64 @nr_read_timeout()
declare i64 @spawnio_off_path_len()
declare i64 @rename_path_ptr(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3)
declare i64 @sockaddr_size()
declare i64 @u32_b0(i64 %arg0)
declare i64 @dirent_off_name_len()

@.site.alloc = private unnamed_addr constant [6 x i8] c"alloc\00"
@.site.matmul = private unnamed_addr constant [7 x i8] c"matmul\00"
@.site.load = private unnamed_addr constant [5 x i8] c"load\00"
@.site.softmax = private unnamed_addr constant [8 x i8] c"softmax\00"
@.site.access = private unnamed_addr constant [7 x i8] c"access\00"
@.site.index = private unnamed_addr constant [6 x i8] c"index\00"

%str.1.ty = type { i64, i64, [19 x i8] }
@.str.1 = private unnamed_addr constant %str.1.ty { i64 0, i64 18, [19 x i8] c"opencode-sal 0.1.0\00" }, align 16
%str.2.ty = type { i64, i64, [2 x i8] }
@.str.2 = private unnamed_addr constant %str.2.ty { i64 0, i64 1, [2 x i8] c"\0A\00" }, align 16
%str.3.ty = type { i64, i64, [10 x i8] }
@.str.3 = private unnamed_addr constant %str.3.ty { i64 0, i64 9, [10 x i8] c"--version\00" }, align 16
%str.4.ty = type { i64, i64, [4 x i8] }
@.str.4 = private unnamed_addr constant %str.4.ty { i64 0, i64 3, [4 x i8] c"run\00" }, align 16
%str.5.ty = type { i64, i64, [1 x i8] }
@.str.5 = private unnamed_addr constant %str.5.ty { i64 0, i64 0, [1 x i8] c"\00" }, align 16
%str.6.ty = type { i64, i64, [9 x i8] }
@.str.6 = private unnamed_addr constant %str.6.ty { i64 0, i64 8, [9 x i8] c"--format\00" }, align 16
%str.7.ty = type { i64, i64, [5 x i8] }
@.str.7 = private unnamed_addr constant %str.7.ty { i64 0, i64 4, [5 x i8] c"json\00" }, align 16
%str.8.ty = type { i64, i64, [6 x i8] }
@.str.8 = private unnamed_addr constant %str.8.ty { i64 0, i64 5, [6 x i8] c"hello\00" }, align 16
%str.9.ty = type { i64, i64, [11 x i8] }
@.str.9 = private unnamed_addr constant %str.9.ty { i64 0, i64 10, [11 x i8] c"reinstalar\00" }, align 16
%str.10.ty = type { i64, i64, [14 x i8] }
@.str.10 = private unnamed_addr constant %str.10.ty { i64 0, i64 13, [14 x i8] c"/bin/soso-pkg\00" }, align 16
%str.11.ty = type { i64, i64, [42 x i8] }
@.str.11 = private unnamed_addr constant %str.11.ty { i64 0, i64 41, [42 x i8] c"uso: opencode [--version|run|reinstalar]\0A\00" }, align 16

define i64 @version_str() {
entry:
  %t1_p = getelementptr inbounds %str.1.ty, ptr @.str.1, i32 0, i32 2, i32 0
  %t1 = ptrtoint ptr %t1_p to i64
  ret i64 %t1
}
define i64 @main(i64 %argc, ptr %argv) {
entry:
  call void @sal_runtime_init(i64 %argc, ptr %argv)
  %t1 = call i64 @sal_argc()
  %t2 = add i64 0, 2
  %t3_c = icmp slt i64 %t1, 2
  %t3 = zext i1 %t3_c to i64
  %ifcond1 = icmp ne i64 %t3, 0
  br i1 %ifcond1, label %then1, label %else1
then1:
  %t4 = add i64 0, 1
  %t5 = call i64 @version_str()
  %t6_p = getelementptr inbounds %str.2.ty, ptr @.str.2, i32 0, i32 2, i32 0
  %t6 = ptrtoint ptr %t6_p to i64
  %cast1 = inttoptr i64 %t5 to ptr
  %cast2 = inttoptr i64 %t6 to ptr
  %t7_p = call ptr @sal_str_concat(ptr %cast1, ptr %cast2)
  %t7 = ptrtoint ptr %t7_p to i64
  %t8 = call i64 @write_str_fd(i64 1, i64 %t7)
  %t9 = add i64 0, 0
  br label %join1
else1:
  %t10 = add i64 0, 1
  %t11_p = call ptr @sal_argv(i64 1)
  %t11 = ptrtoint ptr %t11_p to i64
  %t12_p = getelementptr inbounds %str.3.ty, ptr @.str.3, i32 0, i32 2, i32 0
  %t12 = ptrtoint ptr %t12_p to i64
  %cast3 = inttoptr i64 %t11 to ptr
  %cast4 = inttoptr i64 %t12 to ptr
  %t13 = call i64 @sal_str_eq(ptr %cast3, ptr %cast4)
  %t14 = add i64 0, 0
  %t15_c = icmp ne i64 %t13, 0
  %t15 = zext i1 %t15_c to i64
  %ifcond2 = icmp ne i64 %t15, 0
  br i1 %ifcond2, label %then2, label %else2
then2:
  %t16 = add i64 0, 1
  %t17 = call i64 @version_str()
  %t18_p = getelementptr inbounds %str.2.ty, ptr @.str.2, i32 0, i32 2, i32 0
  %t18 = ptrtoint ptr %t18_p to i64
  %cast5 = inttoptr i64 %t17 to ptr
  %cast6 = inttoptr i64 %t18 to ptr
  %t19_p = call ptr @sal_str_concat(ptr %cast5, ptr %cast6)
  %t19 = ptrtoint ptr %t19_p to i64
  %t20 = call i64 @write_str_fd(i64 1, i64 %t19)
  %t21 = add i64 0, 0
  br label %join2
else2:
  %t22_p = getelementptr inbounds %str.4.ty, ptr @.str.4, i32 0, i32 2, i32 0
  %t22 = ptrtoint ptr %t22_p to i64
  %cast7 = inttoptr i64 %t11 to ptr
  %cast8 = inttoptr i64 %t22 to ptr
  %t23 = call i64 @sal_str_eq(ptr %cast7, ptr %cast8)
  %t24 = add i64 0, 0
  %t25_c = icmp ne i64 %t23, 0
  %t25 = zext i1 %t25_c to i64
  %ifcond3 = icmp ne i64 %t25, 0
  br i1 %ifcond3, label %then3, label %else3
then3:
  %t26 = add i64 0, 0
  %t27_p = getelementptr inbounds %str.5.ty, ptr @.str.5, i32 0, i32 2, i32 0
  %t27 = ptrtoint ptr %t27_p to i64
  %t28 = call i64 @sal_argc()
  %t29 = add i64 0, 3
  %t30_c = icmp sge i64 %t28, 3
  %t30 = zext i1 %t30_c to i64
  %ifcond4 = icmp ne i64 %t30, 0
  br i1 %ifcond4, label %then4, label %else4
then4:
  %t31 = add i64 0, 2
  %t32_p = call ptr @sal_argv(i64 2)
  %t32 = ptrtoint ptr %t32_p to i64
  %t33_p = getelementptr inbounds %str.6.ty, ptr @.str.6, i32 0, i32 2, i32 0
  %t33 = ptrtoint ptr %t33_p to i64
  %cast9 = inttoptr i64 %t32 to ptr
  %cast10 = inttoptr i64 %t33 to ptr
  %t34 = call i64 @sal_str_eq(ptr %cast9, ptr %cast10)
  %t35 = add i64 0, 0
  %t36_c = icmp ne i64 %t34, 0
  %t36 = zext i1 %t36_c to i64
  %ifcond5 = icmp ne i64 %t36, 0
  br i1 %ifcond5, label %then5, label %else5
then5:
  %t37 = call i64 @sal_argc()
  %t38 = add i64 0, 5
  %t39_c = icmp sge i64 %t37, 5
  %t39 = zext i1 %t39_c to i64
  %ifcond6 = icmp ne i64 %t39, 0
  br i1 %ifcond6, label %then6, label %else6
then6:
  %t40 = add i64 0, 3
  %t41_p = call ptr @sal_argv(i64 3)
  %t41 = ptrtoint ptr %t41_p to i64
  %t42_p = getelementptr inbounds %str.7.ty, ptr @.str.7, i32 0, i32 2, i32 0
  %t42 = ptrtoint ptr %t42_p to i64
  %cast11 = inttoptr i64 %t41 to ptr
  %cast12 = inttoptr i64 %t42 to ptr
  %t43 = call i64 @sal_str_eq(ptr %cast11, ptr %cast12)
  %t44 = add i64 0, 0
  %t45_c = icmp ne i64 %t43, 0
  %t45 = zext i1 %t45_c to i64
  %ifcond7 = icmp ne i64 %t45, 0
  br i1 %ifcond7, label %then7, label %else7
then7:
  %t46 = add i64 0, 1
  %t47 = add i64 0, 0
  br label %join7
else7:
  %t48 = add i64 0, 0
  br label %join7
join7:
  %t49 = phi i64 [ 0, %then7 ], [ 0, %else7 ]
  %t50 = phi i64 [ 1, %then7 ], [ %t26, %else7 ]
  %t51 = add i64 0, 4
  %t52_p = call ptr @sal_argv(i64 4)
  %t52 = ptrtoint ptr %t52_p to i64
  %t53 = add i64 0, 0
  br label %join6
else6:
  %t54 = add i64 0, 0
  br label %join6
join6:
  %t55 = phi i64 [ 0, %join7 ], [ 0, %else6 ]
  %t56 = phi i64 [ %t50, %join7 ], [ %t26, %else6 ]
  %t57 = phi i64 [ %t52, %join7 ], [ %t27, %else6 ]
  br label %join5
else5:
  %t58 = add i64 0, 2
  %t59_p = call ptr @sal_argv(i64 2)
  %t59 = ptrtoint ptr %t59_p to i64
  %t60 = add i64 0, 0
  br label %join5
join5:
  %t61 = phi i64 [ %t55, %join6 ], [ 0, %else5 ]
  %t62 = phi i64 [ %t56, %join6 ], [ %t26, %else5 ]
  %t63 = phi i64 [ %t57, %join6 ], [ %t59, %else5 ]
  br label %join4
else4:
  %t64 = add i64 0, 0
  br label %join4
join4:
  %t65 = phi i64 [ %t61, %join5 ], [ 0, %else4 ]
  %t66 = phi i64 [ %t62, %join5 ], [ %t26, %else4 ]
  %t67 = phi i64 [ %t63, %join5 ], [ %t27, %else4 ]
  %cast13 = inttoptr i64 %t67 to ptr
  %t68 = call i64 @sal_str_len(ptr %cast13)
  %t69 = add i64 0, 0
  %t70_c = icmp sle i64 %t68, 0
  %t70 = zext i1 %t70_c to i64
  %ifcond8 = icmp ne i64 %t70, 0
  br i1 %ifcond8, label %then8, label %else8
then8:
  %t71_p = getelementptr inbounds %str.8.ty, ptr @.str.8, i32 0, i32 2, i32 0
  %t71 = ptrtoint ptr %t71_p to i64
  %t72 = add i64 0, 0
  br label %join8
else8:
  %t73 = add i64 0, 0
  br label %join8
join8:
  %t74 = phi i64 [ 0, %then8 ], [ 0, %else8 ]
  %t75 = phi i64 [ %t71, %then8 ], [ %t67, %else8 ]
  %t76 = call i64 @run_once(i64 %t75, i64 %t66)
  br label %join3
else3:
  %t77_p = getelementptr inbounds %str.9.ty, ptr @.str.9, i32 0, i32 2, i32 0
  %t77 = ptrtoint ptr %t77_p to i64
  %cast14 = inttoptr i64 %t11 to ptr
  %cast15 = inttoptr i64 %t77 to ptr
  %t78 = call i64 @sal_str_eq(ptr %cast14, ptr %cast15)
  %t79 = add i64 0, 0
  %t80_c = icmp ne i64 %t78, 0
  %t80 = zext i1 %t80_c to i64
  %ifcond9 = icmp ne i64 %t80, 0
  br i1 %ifcond9, label %then9, label %else9
then9:
  %t81_p = getelementptr inbounds %str.10.ty, ptr @.str.10, i32 0, i32 2, i32 0
  %t81 = ptrtoint ptr %t81_p to i64
  %t82 = add i64 0, 0
  %t83 = add i64 0, 1
  %t84 = add i64 0, 2
  %t85 = add i64 0, 1
  %t86 = sub i64 0, 1
  %t87 = call i64 @spawn_io_full(i64 %t81, i64 0, i64 1, i64 2, i64 %t86)
  %t88 = add i64 0, 0
  br label %join9
else9:
  %t89 = add i64 0, 2
  %t90_p = getelementptr inbounds %str.11.ty, ptr @.str.11, i32 0, i32 2, i32 0
  %t90 = ptrtoint ptr %t90_p to i64
  %t91 = call i64 @write_str_fd(i64 2, i64 %t90)
  %t92 = add i64 0, 2
  br label %join9
join9:
  %t93 = phi i64 [ 0, %then9 ], [ 2, %else9 ]
  br label %join3
join3:
  %t94 = phi i64 [ %t76, %join8 ], [ %t93, %join9 ]
  br label %join2
join2:
  %t95 = phi i64 [ 0, %then2 ], [ %t94, %join3 ]
  br label %join1
join1:
  %t96 = phi i64 [ 0, %then1 ], [ %t95, %join2 ]
  ret i64 %t96
}
