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

declare i64 @o_CREAT()
declare i64 @spawnio_off_path_len()
declare i64 @spawnio_off_stderr()
declare i64 @nr_uptime_ms()
declare i64 @o_WRONLY()
declare i64 @nr_tcp_listen()
declare i64 @spawnio_size()
declare i64 @nr_stat()
declare i64 @spawnio_off_stdout()
declare i64 @spawnio_off_argv_count()
declare i64 @nr_tcp_accept()
declare i64 @spawnio_off_log_fd()
declare i64 @sockaddr_size()
declare i64 @write_str_fd(i64 %arg0, i64 %arg1)
declare i64 @nr_unlink()
declare i64 @open_flags(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @nr_getenv()
declare i64 @dirent_off_name()
declare i64 @spawnio_off_path_ptr()
declare i64 @dirent_off_ino()
declare i64 @nr_open()
declare i64 @spawnio_off_stdin()
declare i64 @nr_spawn_io()
declare i64 @nr_kill()
declare i64 @dirent_off_name_len()
declare i64 @read_timeout_fd(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3)
declare i64 @dirent_off_file_type()
declare i64 @nr_read()
declare i64 @nr_wait()
declare i64 @close_fd(i64 %arg0)
declare i64 @open_read_path_ptr(i64 %arg0, i64 %arg1)
declare i64 @write_fd(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @nr_mkdir()
declare i64 @nr_write()
declare i64 @nr_rename()
declare i64 @o_RDONLY()
declare i64 @spawnio_off_argv_ptr()
declare i64 @dirent_size()
declare i64 @nr_getdents()
declare i64 @ft_file()
declare i64 @nr_close()
declare i64 @nr_read_timeout()
declare i64 @nr_tcp_connect()
declare i64 @ft_dir()
declare i64 @nr_dns_resolve()
declare i64 @read_fd(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @nr_sleep_ms()

@.site.alloc = private unnamed_addr constant [6 x i8] c"alloc\00"
@.site.matmul = private unnamed_addr constant [7 x i8] c"matmul\00"
@.site.load = private unnamed_addr constant [5 x i8] c"load\00"
@.site.softmax = private unnamed_addr constant [8 x i8] c"softmax\00"
@.site.access = private unnamed_addr constant [7 x i8] c"access\00"
@.site.index = private unnamed_addr constant [6 x i8] c"index\00"

define i64 @getdents_fd(i64 %fd, i64 %buf_ptr, i64 %buf_len) {
entry:
  %t1 = call i64 @nr_getdents()
  %t2 = add i64 0, 0
  %t3 = add i64 0, 0
  %t4 = add i64 0, 0
  %t5 = call i64 @sal_os_syscall(i64 %t1, i64 %fd, i64 %buf_ptr, i64 %buf_len, i64 0, i64 0, i64 0)
  ret i64 %t5
}
define i64 @stat_path_ptr(i64 %path_ptr, i64 %path_len, i64 %out_ptr, i64 %out_len) {
entry:
  %t1 = call i64 @nr_stat()
  %t2 = add i64 0, 0
  %t3 = add i64 0, 0
  %t4 = call i64 @sal_os_syscall(i64 %t1, i64 %path_ptr, i64 %path_len, i64 %out_ptr, i64 %out_len, i64 0, i64 0)
  ret i64 %t4
}
define i64 @mkdir_path_ptr(i64 %path_ptr, i64 %path_len) {
entry:
  %t1 = call i64 @nr_mkdir()
  %t2 = add i64 0, 0
  %t3 = add i64 0, 0
  %t4 = add i64 0, 0
  %t5 = add i64 0, 0
  %t6 = call i64 @sal_os_syscall(i64 %t1, i64 %path_ptr, i64 %path_len, i64 0, i64 0, i64 0, i64 0)
  ret i64 %t6
}
define i64 @unlink_path_ptr(i64 %path_ptr, i64 %path_len) {
entry:
  %t1 = call i64 @nr_unlink()
  %t2 = add i64 0, 0
  %t3 = add i64 0, 0
  %t4 = add i64 0, 0
  %t5 = add i64 0, 0
  %t6 = call i64 @sal_os_syscall(i64 %t1, i64 %path_ptr, i64 %path_len, i64 0, i64 0, i64 0, i64 0)
  ret i64 %t6
}
define i64 @rename_path_ptr(i64 %old_ptr, i64 %old_len, i64 %new_ptr, i64 %new_len) {
entry:
  %t1 = call i64 @nr_rename()
  %t2 = add i64 0, 0
  %t3 = add i64 0, 0
  %t4 = call i64 @sal_os_syscall(i64 %t1, i64 %old_ptr, i64 %old_len, i64 %new_ptr, i64 %new_len, i64 0, i64 0)
  ret i64 %t4
}
define i64 @path_to_buf(i64 %path) {
entry:
  %cast1 = inttoptr i64 %path to ptr
  %t1 = call i64 @sal_str_len(ptr %cast1)
  %t2 = add i64 0, 1
  %t3 = add i64 %t1, 1
  %t4_p = call ptr @sal_bytes_new(i64 %t3)
  %t4 = ptrtoint ptr %t4_p to i64
  %t5 = add i64 0, 0
  %cast2 = inttoptr i64 %t4 to ptr
  %cast3 = inttoptr i64 %path to ptr
  %t6 = call i64 @sal_str_bytes_copy(ptr %cast2, i64 0, ptr %cast3)
  ret i64 %t4
}
define i64 @open_read(i64 %path) {
entry:
  %t1 = call i64 @path_to_buf(i64 %path)
  %cast1 = inttoptr i64 %t1 to ptr
  %t2 = call i64 @sal_bytes_ptr(ptr %cast1)
  %cast2 = inttoptr i64 %path to ptr
  %t3 = call i64 @sal_str_len(ptr %cast2)
  %t4 = tail call i64 @open_read_path_ptr(i64 %t2, i64 %t3)
  ret i64 %t4
}
define i64 @write_file_path(i64 %path, i64 %data) {
entry:
  %t1 = call i64 @path_to_buf(i64 %path)
  %cast1 = inttoptr i64 %t1 to ptr
  %t2 = call i64 @sal_bytes_ptr(ptr %cast1)
  %cast2 = inttoptr i64 %path to ptr
  %t3 = call i64 @sal_str_len(ptr %cast2)
  %t4 = call i64 @o_WRONLY()
  %t5 = call i64 @o_CREAT()
  %t6 = add i64 %t4, %t5
  %t7 = call i64 @open_flags(i64 %t2, i64 %t3, i64 %t6)
  %t8 = add i64 0, 0
  %t9_c = icmp slt i64 %t7, 0
  %t9 = zext i1 %t9_c to i64
  %ifcond1 = icmp ne i64 %t9, 0
  br i1 %ifcond1, label %then1, label %else1
then1:
  ret i64 %t7
else1:
  %t10 = call i64 @write_str_fd(i64 %t7, i64 %data)
  %t11 = call i64 @close_fd(i64 %t7)
  ret i64 %t10
}
