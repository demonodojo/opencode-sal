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

declare i64 @ft_file()
declare i64 @spawnio_off_stdin()
declare i64 @tcp_listen(i64 %arg0)
declare i64 @spawnio_off_stdout()
declare i64 @nr_unlink()
declare i64 @nr_dns_resolve()
declare i64 @sse_stub_content()
declare i64 @close_fd(i64 %arg0)
declare i64 @nr_read()
declare i64 @nr_mkdir()
declare i64 @http_read_body(i64 %arg0, i64 %arg1)
declare i64 @read_fd(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @nr_kill()
declare i64 @nr_getdents()
declare i64 @dirent_off_name()
declare i64 @nr_open()
declare i64 @tcp_connect_loopback(i64 %arg0, i64 %arg1)
declare i64 @nr_tcp_connect()
declare i64 @nr_rename()
declare i64 @agents_md()
declare i64 @nr_read_timeout()
declare i64 @nr_uptime_ms()
declare i64 @o_WRONLY()
declare i64 @dirent_size()
declare i64 @spawnio_off_path_ptr()
declare i64 @dirent_off_file_type()
declare i64 @mod_pos(i64 %arg0, i64 %arg1)
declare i64 @json_emit_done()
declare i64 @nr_sleep_ms()
declare i64 @nr_tcp_listen()
declare i64 @nr_write()
declare i64 @spawnio_size()
declare i64 @spawnio_off_argv_count()
declare i64 @config_model()
declare i64 @unlink_path_ptr(i64 %arg0, i64 %arg1)
declare i64 @nr_close()
declare i64 @dirent_off_ino()
declare i64 @write_fd(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @http_post(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @u32_b2(i64 %arg0)
declare i64 @dns_resolve_ptr(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @json_emit_line(i64 %arg0, i64 %arg1)
declare i64 @open_read_path_ptr(i64 %arg0, i64 %arg1)
declare i64 @session_load(i64 %arg0)
declare i64 @spawnio_off_path_len()
declare i64 @spawnio_off_argv_ptr()
declare i64 @nr_getenv()
declare i64 @write_file_path(i64 %arg0, i64 %arg1)
declare i64 @u8(i64 %arg0)
declare i64 @write_str_fd(i64 %arg0, i64 %arg1)
declare i64 @open_flags(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @nr_tcp_accept()
declare i64 @spawnio_off_stderr()
declare i64 @path_to_buf(i64 %arg0)
declare i64 @tcp_accept(i64 %arg0, i64 %arg1)
declare i64 @o_CREAT()
declare i64 @json_esc(i64 %arg0)
declare i64 @read_timeout_fd(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3)
declare i64 @o_RDONLY()
declare i64 @nr_spawn_io()
declare i64 @sockaddr_loopback(i64 %arg0)
declare i64 @stat_path_ptr(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3)
declare i64 @ft_dir()
declare i64 @session_path(i64 %arg0)
declare i64 @spawnio_off_log_fd()
declare i64 @mkdir_path_ptr(i64 %arg0, i64 %arg1)
declare i64 @rename_path_ptr(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3)
declare i64 @nr_wait()
declare i64 @u32_b0(i64 %arg0)
declare i64 @dirent_off_name_len()
declare i64 @open_read(i64 %arg0)
declare i64 @config_base_url()
declare i64 @getdents_fd(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @sockaddr_size()
declare i64 @sse_has_data(i64 %arg0)
declare i64 @session_save(i64 %arg0, i64 %arg1)
declare i64 @nr_stat()

@.site.alloc = private unnamed_addr constant [6 x i8] c"alloc\00"
@.site.matmul = private unnamed_addr constant [7 x i8] c"matmul\00"
@.site.load = private unnamed_addr constant [5 x i8] c"load\00"
@.site.softmax = private unnamed_addr constant [8 x i8] c"softmax\00"
@.site.access = private unnamed_addr constant [7 x i8] c"access\00"
@.site.index = private unnamed_addr constant [6 x i8] c"index\00"

%str.1.ty = type { i64, i64, [23 x i8] }
@.str.1 = private unnamed_addr constant %str.1.ty { i64 0, i64 22, [23 x i8] c"model=soso-coder user=\00" }, align 16
%str.2.ty = type { i64, i64, [21 x i8] }
@.str.2 = private unnamed_addr constant %str.2.ty { i64 0, i64 20, [21 x i8] c"/v1/chat/completions\00" }, align 16
%str.3.ty = type { i64, i64, [5 x i8] }
@.str.3 = private unnamed_addr constant %str.3.ty { i64 0, i64 4, [5 x i8] c"text\00" }, align 16
%str.4.ty = type { i64, i64, [3 x i8] }
@.str.4 = private unnamed_addr constant %str.4.ty { i64 0, i64 2, [3 x i8] c"ok\00" }, align 16
%str.5.ty = type { i64, i64, [5 x i8] }
@.str.5 = private unnamed_addr constant %str.5.ty { i64 0, i64 4, [5 x i8] c"last\00" }, align 16
%str.6.ty = type { i64, i64, [8 x i8] }
@.str.6 = private unnamed_addr constant %str.6.ty { i64 0, i64 7, [8 x i8] c"content\00" }, align 16
%str.7.ty = type { i64, i64, [6 x i8] }
@.str.7 = private unnamed_addr constant %str.7.ty { i64 0, i64 5, [6 x i8] c"model\00" }, align 16

define i64 @chat_body(i64 %prompt, i64 %_model) {
entry:
  %t1_p = getelementptr inbounds %str.1.ty, ptr @.str.1, i32 0, i32 2, i32 0
  %t1 = ptrtoint ptr %t1_p to i64
  %t2 = call i64 @json_esc(i64 %prompt)
  %cast1 = inttoptr i64 %t1 to ptr
  %cast2 = inttoptr i64 %t2 to ptr
  %t3_p = call ptr @sal_str_concat(ptr %cast1, ptr %cast2)
  %t3 = ptrtoint ptr %t3_p to i64
  ret i64 %t3
}
define i64 @run_once(i64 %prompt, i64 %json_out) {
entry:
  %t1 = call i64 @config_model()
  %t2 = call i64 @chat_body(i64 %prompt, i64 %t1)
  %t3 = add i64 0, 7422
  %t4_p = getelementptr inbounds %str.2.ty, ptr @.str.2, i32 0, i32 2, i32 0
  %t4 = ptrtoint ptr %t4_p to i64
  %t5 = call i64 @http_post(i64 7422, i64 %t4, i64 %t2)
  %t6 = call i64 @sse_has_data(i64 %t5)
  %t7 = add i64 0, 0
  %t8_c = icmp ne i64 %t6, 0
  %t8 = zext i1 %t8_c to i64
  %ifcond1 = icmp ne i64 %t8, 0
  br i1 %ifcond1, label %then1, label %else1
then1:
  %t9_p = getelementptr inbounds %str.3.ty, ptr @.str.3, i32 0, i32 2, i32 0
  %t9 = ptrtoint ptr %t9_p to i64
  %t10_p = getelementptr inbounds %str.4.ty, ptr @.str.4, i32 0, i32 2, i32 0
  %t10 = ptrtoint ptr %t10_p to i64
  %t11 = call i64 @json_emit_line(i64 %t9, i64 %t10)
  %t12 = add i64 0, 0
  %t13_c = icmp ne i64 %json_out, 0
  %t13 = zext i1 %t13_c to i64
  %ifcond2 = icmp ne i64 %t13, 0
  br i1 %ifcond2, label %then2, label %else2
then2:
  %t14 = add i64 0, 1
  %t15 = call i64 @write_str_fd(i64 1, i64 %t11)
  %t16 = add i64 0, 0
  br label %join2
else2:
  %t17 = add i64 0, 0
  br label %join2
join2:
  %t18 = phi i64 [ 0, %then2 ], [ 0, %else2 ]
  %t19_p = getelementptr inbounds %str.5.ty, ptr @.str.5, i32 0, i32 2, i32 0
  %t19 = ptrtoint ptr %t19_p to i64
  %t20 = call i64 @session_save(i64 %t19, i64 %t5)
  %t21 = add i64 0, 0
  ret i64 0
else1:
  %t22_p = getelementptr inbounds %str.6.ty, ptr @.str.6, i32 0, i32 2, i32 0
  %t22 = ptrtoint ptr %t22_p to i64
  %cast1 = inttoptr i64 %t5 to ptr
  %cast2 = inttoptr i64 %t22 to ptr
  %t23 = call i64 @sal_str_contains(ptr %cast1, ptr %cast2)
  %t24 = add i64 0, 0
  %t25_c = icmp ne i64 %t23, 0
  %t25 = zext i1 %t25_c to i64
  %ifcond3 = icmp ne i64 %t25, 0
  br i1 %ifcond3, label %then3, label %else3
then3:
  %t26_p = getelementptr inbounds %str.3.ty, ptr @.str.3, i32 0, i32 2, i32 0
  %t26 = ptrtoint ptr %t26_p to i64
  %t27_p = getelementptr inbounds %str.7.ty, ptr @.str.7, i32 0, i32 2, i32 0
  %t27 = ptrtoint ptr %t27_p to i64
  %t28 = call i64 @json_emit_line(i64 %t26, i64 %t27)
  %t29 = add i64 0, 0
  %t30_c = icmp ne i64 %json_out, 0
  %t30 = zext i1 %t30_c to i64
  %ifcond4 = icmp ne i64 %t30, 0
  br i1 %ifcond4, label %then4, label %else4
then4:
  %t31 = add i64 0, 1
  %t32 = call i64 @write_str_fd(i64 1, i64 %t28)
  %t33 = add i64 0, 0
  br label %join4
else4:
  %t34 = add i64 0, 0
  br label %join4
join4:
  %t35 = phi i64 [ 0, %then4 ], [ 0, %else4 ]
  %t36 = add i64 0, 1
  %t37 = call i64 @json_emit_done()
  %t38 = call i64 @write_str_fd(i64 1, i64 %t37)
  %t39 = add i64 0, 0
  ret i64 0
else3:
  %t40 = add i64 0, 1
  ret i64 1
}
